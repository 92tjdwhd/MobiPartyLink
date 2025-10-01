import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type'
};

interface DataUpdateRequest {
  data_type?: string;
  version?: number;
  updated_at?: string;
  // Webhook payload
  type?: 'INSERT' | 'UPDATE' | 'DELETE';
  table?: string;
  record?: any;
  old_record?: any;
}

serve(async (req) => {
  // CORS Preflight 처리
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const requestBody: DataUpdateRequest = await req.json();
    
    // Webhook 요청인지 직접 호출인지 구분
    let data_type: string;
    let version: number;
    let updated_at: string;

    if (requestBody.type === 'UPDATE' && requestBody.table === 'data_versions') {
      // Database Webhook 요청
      console.log('📩 Webhook 수신: data_versions UPDATE');
      data_type = requestBody.record.data_type;
      version = requestBody.record.version;
      updated_at = requestBody.record.last_updated;
    } else {
      // 직접 호출 요청
      data_type = requestBody.data_type!;
      version = requestBody.version!;
      updated_at = requestBody.updated_at || new Date().toISOString();
    }

    console.log('📩 데이터 업데이트 FCM 요청:', { data_type, version });

    // Firebase Service Account Key 가져오기
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

    // Topic으로 FCM 전송 (all_users)
    const fcmResponse = await fetch(
      `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
      {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${accessToken}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          message: {
            topic: 'all_users',
            data: {
              type: 'data_update',
              data_type: data_type,
              version: version.toString(),
              updated_at: updated_at || new Date().toISOString(),
              click_action: 'FLUTTER_NOTIFICATION_CLICK'
            }
          }
        })
      }
    );

    const fcmResult = await fcmResponse.json();
    console.log('✅ 데이터 업데이트 FCM 전송 성공:', fcmResult);

    return new Response(
      JSON.stringify({
        success: true,
        data_type,
        version,
        fcmResult
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    );
  } catch (error) {
    console.error('❌ Edge Function 에러:', error);
    return new Response(
      JSON.stringify({
        error: error.message
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500
      }
    );
  }
});

// JWT 생성 함수
async function createJWT(serviceAccount: any): Promise<string> {
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
  const base64UrlEncode = (str: string) =>
    btoa(str)
      .replace(/\+/g, '-')
      .replace(/\//g, '_')
      .replace(/=/g, '');

  const headerB64 = base64UrlEncode(JSON.stringify(header));
  const payloadB64 = base64UrlEncode(JSON.stringify(payload));

  // Private Key 파싱 및 서명
  const privateKey = serviceAccount.private_key
    .replace(/-----BEGIN PRIVATE KEY-----/, '')
    .replace(/-----END PRIVATE KEY-----/, '')
    .replace(/\n/g, '');

  const binaryKey = Uint8Array.from(atob(privateKey), c => c.charCodeAt(0));

  const cryptoKey = await crypto.subtle.importKey(
    'pkcs8',
    binaryKey,
    {
      name: 'RSASSA-PKCS1-v1_5',
      hash: 'SHA-256'
    },
    false,
    ['sign']
  );

  const signatureData = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    cryptoKey,
    new TextEncoder().encode(`${headerB64}.${payloadB64}`)
  );

  const signatureB64 = base64UrlEncode(
    String.fromCharCode(...new Uint8Array(signatureData))
  );

  return `${headerB64}.${payloadB64}.${signatureB64}`;
}

