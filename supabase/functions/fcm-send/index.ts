import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type'
};
serve(async (req)=>{
  // CORS Preflight 처리
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: corsHeaders
    });
  }
  try {
    const requestBody = await req.json();
    // Webhook 요청인지 직접 호출인지 구분
    if (requestBody.type && requestBody.table) {
      // Database Webhook 요청
      console.log('📩 Webhook 수신:', requestBody.type, requestBody.table);
      return await handleWebhook(requestBody);
    } else {
      // 직접 FCM 전송 요청
      const { fcm_tokens, title, body, data } = requestBody;
      if (!fcm_tokens || fcm_tokens.length === 0) {
        return new Response(JSON.stringify({
          error: 'fcm_tokens required'
        }), {
          headers: {
            ...corsHeaders,
            'Content-Type': 'application/json'
          },
          status: 400
        });
      }
      return await sendFCM(fcm_tokens, title, body, data || {});
    }
  } catch (error) {
    console.error('❌ Edge Function 에러:', error);
    return new Response(JSON.stringify({
      error: error.message
    }), {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json'
      },
      status: 500
    });
  }
});
// JWT 생성 함수
async function createJWT(serviceAccount) {
  const header = {
    alg: 'RS256',
    typ: 'JWT'
  };
  const now = Math.floor(Date.now() / 1000);
  const payload = {
    iss: serviceAccount.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    exp: now + 3600,
    iat: now
  };
  // Base64 URL-safe 인코딩
  const base64UrlEncode = (str)=>btoa(str).replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '');
  const headerB64 = base64UrlEncode(JSON.stringify(header));
  const payloadB64 = base64UrlEncode(JSON.stringify(payload));
  // Private Key 파싱 및 서명
  const privateKey = serviceAccount.private_key.replace(/-----BEGIN PRIVATE KEY-----/, '').replace(/-----END PRIVATE KEY-----/, '').replace(/\n/g, '');
  console.log('🔑 Private Key 길이:', privateKey.length);
  const binaryKey = Uint8Array.from(atob(privateKey), (c)=>c.charCodeAt(0));
  const cryptoKey = await crypto.subtle.importKey('pkcs8', binaryKey, {
    name: 'RSASSA-PKCS1-v1_5',
    hash: 'SHA-256'
  }, false, [
    'sign'
  ]);
  const signatureData = await crypto.subtle.sign('RSASSA-PKCS1-v1_5', cryptoKey, new TextEncoder().encode(`${headerB64}.${payloadB64}`));
  const signatureB64 = base64UrlEncode(String.fromCharCode(...new Uint8Array(signatureData)));
  return `${headerB64}.${payloadB64}.${signatureB64}`;
}
// Webhook 처리 함수
async function handleWebhook(payload) {
  const { type, table, record, old_record } = payload;
  if (table === 'parties') {
    return await handlePartyWebhook(type, record, old_record);
  } else if (table === 'party_members') {
    return await handlePartyMemberWebhook(type, record, old_record);
  }
  return new Response(JSON.stringify({
    error: 'Unknown table'
  }), {
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json'
    },
    status: 400
  });
}
// 파티 테이블 Webhook 처리
async function handlePartyWebhook(type, record, old_record) {
  const supabaseUrl = Deno.env.get('SUPABASE_URL');
  const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY');
  const supabase = createClient(supabaseUrl, supabaseKey);
  const partyId = type === 'DELETE' ? old_record.id : record.id;
  const partyName = type === 'DELETE' ? old_record.name : record.name;
  // 파티 멤버들의 FCM 토큰 조회
  const { data: members, error } = await supabase.from('party_members').select('fcm_token').eq('party_id', partyId).not('fcm_token', 'is', null);
  if (error) {
    console.error('❌ 멤버 조회 실패:', error);
    return new Response(JSON.stringify({
      error: error.message
    }), {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json'
      },
      status: 500
    });
  }
  const fcmTokens = members?.map((m)=>m.fcm_token).filter((t)=>t) || [];
  if (fcmTokens.length === 0) {
    console.log('⚠️ FCM 토큰이 없음');
    return new Response(JSON.stringify({
      success: true,
      sent: 0,
      message: 'No FCM tokens'
    }), {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json'
      }
    });
  }
  // FCM 전송
  let title = '';
  let body = '';
  let eventType = '';
  if (type === 'UPDATE') {
    title = '파티 정보 변경';
    body = `[${partyName}] 파티 정보가 변경되었습니다`;
    eventType = 'party_update';
  } else if (type === 'DELETE') {
    title = '파티 삭제';
    body = `[${partyName}] 파티가 삭제되었습니다`;
    eventType = 'party_delete';
  }
  return await sendFCM(fcmTokens, title, body, {
    type: eventType,
    party_name: partyName
  });
}
// 파티 멤버 테이블 Webhook 처리 (강퇴 또는 파티 삭제)
async function handlePartyMemberWebhook(type, record, old_record) {
  if (type !== 'DELETE') {
    return new Response(JSON.stringify({
      success: true,
      message: 'Not a DELETE event'
    }), {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json'
      }
    });
  }
  const fcmToken = old_record.fcm_token;
  if (!fcmToken) {
    return new Response(JSON.stringify({
      success: true,
      message: 'No FCM token'
    }), {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json'
      }
    });
  }
  // 파티 존재 여부 확인
  const supabaseUrl = Deno.env.get('SUPABASE_URL');
  const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY');
  const supabase = createClient(supabaseUrl, supabaseKey);
  const { data: party, error } = await supabase.from('parties').select('name').eq('id', old_record.party_id).single();
  // 파티가 존재하지 않으면 파티 삭제, 존재하면 강퇴
  if (!party || error) {
    // 파티 삭제됨
    console.log('✅ 파티 삭제로 인한 멤버 제거');
    return new Response(JSON.stringify({
      success: true,
      message: 'Party deleted, skip notification'
    }), {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json'
      }
    });
  } else {
    // 강퇴됨
    console.log('✅ 멤버 강퇴');
    return await sendFCM([
      fcmToken
    ], '파티알림', `[${party.name}] 파티에서 나갔습니다.`, {
      type: 'member_kicked',
      party_name: party.name
    });
  }
}
// FCM 전송 공통 함수
async function sendFCM(fcmTokens, title, body, data) {
  console.log('📩 FCM 전송 시작:', {
    tokens: fcmTokens.length,
    title
  });
  const serviceAccountKey = Deno.env.get('FIREBASE_SERVICE_ACCOUNT_KEY');
  if (!serviceAccountKey) {
    throw new Error('Firebase Service Account Key not found');
  }
  const serviceAccount = JSON.parse(serviceAccountKey);
  // OAuth 2.0 액세스 토큰 생성
  const tokenResponse = await fetch(`https://oauth2.googleapis.com/token`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: await createJWT(serviceAccount)
    })
  });
  const tokenData = await tokenResponse.json();
  const accessToken = tokenData.access_token;
  // 각 FCM 토큰에 대해 메시지 전송
  const sendPromises = fcmTokens.map(async (token)=>{
    try {
      const fcmResponse = await fetch(`https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${accessToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          message: {
            token: token,
            notification: {
              title,
              body
            },
            data: data || {},
            android: {
              notification: {
                channel_id: 'party_notification_channel',
                sound: 'default'
              }
            },
            apns: {
              payload: {
                aps: {
                  sound: 'default'
                }
              }
            }
          }
        })
      });
      const result = await fcmResponse.json();
      console.log('✅ FCM 전송 성공:', token.substring(0, 20));
      return {
        success: true,
        token,
        result
      };
    } catch (error) {
      console.error('❌ FCM 전송 실패:', token.substring(0, 20), error);
      return {
        success: false,
        token,
        error: error.message
      };
    }
  });
  const results = await Promise.all(sendPromises);
  const successCount = results.filter((r)=>r.success).length;
  return new Response(JSON.stringify({
    success: true,
    total: fcmTokens.length,
    sent: successCount,
    failed: fcmTokens.length - successCount,
    results
  }), {
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json'
    }
  });
}
