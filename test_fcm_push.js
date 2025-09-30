#!/usr/bin/env node

/**
 * FCM 테스트 푸시 전송 스크립트
 * 
 * 사용법:
 *   node test_fcm_push.js jobs 2
 *   node test_fcm_push.js party_templates 2
 */

const https = require('https');

// ⚠️ FCM 서버 키를 여기에 입력하세요!
// Firebase Console → 프로젝트 설정 → 클라우드 메시징 → 서버 키
const FCM_SERVER_KEY = 'YOUR_FCM_SERVER_KEY_HERE';

// 명령줄 인자
const dataType = process.argv[2] || 'jobs';
const version = process.argv[3] || '2';

if (FCM_SERVER_KEY === 'YOUR_FCM_SERVER_KEY_HERE') {
  console.error('❌ FCM 서버 키를 설정해주세요!');
  console.error('   Firebase Console → 프로젝트 설정 → 클라우드 메시징 → 서버 키');
  process.exit(1);
}

// 알림 메시지 설정
const getNotificationMessage = (dataType) => {
  if (dataType === 'jobs') {
    return {
      title: '새로운 직업 추가!',
      body: '새로운 직업이 추가되었습니다 🎮'
    };
  } else if (dataType === 'party_templates') {
    return {
      title: '새로운 템플릿 추가!',
      body: '새로운 파티 템플릿이 추가되었습니다 🎉'
    };
  } else {
    return {
      title: '콘텐츠 업데이트!',
      body: '새로운 콘텐츠가 업데이트되었습니다'
    };
  }
};

const notification = getNotificationMessage(dataType);

// FCM 페이로드 (iOS + Android 백그라운드 지원)
const payload = {
  to: '/topics/all_users',
  priority: 'high',
  content_available: true,  // iOS 백그라운드 수신을 위해 필수!
  
  // 데이터 페이로드 (백그라운드에서도 수신!)
  data: {
    type: 'data_update',
    data_type: dataType,
    version: version,
    updated_at: new Date().toISOString(),
    click_action: 'FLUTTER_NOTIFICATION_CLICK'
  },
  
  // 알림 페이로드
  notification: {
    title: notification.title,
    body: notification.body,
    sound: 'default',
    badge: '1'
  },
  
  // Android 전용 설정
  android: {
    priority: 'high',
    notification: {
      channel_id: 'data_update_channel',
      sound: 'default',
      priority: 'high',
      default_vibrate_timings: true,
      notification_count: 1
    }
  },
  
  // iOS 전용 설정 (APNS)
  apns: {
    headers: {
      'apns-priority': '10'
    },
    payload: {
      aps: {
        alert: {
          title: notification.title,
          body: notification.body
        },
        sound: 'default',
        badge: 1,
        'content-available': 1  // iOS 백그라운드 수신 필수!
      }
    }
  }
};

const postData = JSON.stringify(payload);

const options = {
  hostname: 'fcm.googleapis.com',
  port: 443,
  path: '/fcm/send',
  method: 'POST',
  headers: {
    'Authorization': `key=${FCM_SERVER_KEY}`,
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(postData)
  }
};

console.log('📤 FCM 푸시 전송 중...');
console.log(`   토픽: /topics/all_users`);
console.log(`   데이터 타입: ${dataType}`);
console.log(`   버전: ${version}`);
console.log('');

const req = https.request(options, (res) => {
  let body = '';
  
  res.on('data', (chunk) => {
    body += chunk;
  });
  
  res.on('end', () => {
    const response = JSON.parse(body);
    console.log('✅ FCM 전송 완료!');
    console.log('');
    console.log('📊 응답:');
    console.log(JSON.stringify(response, null, 2));
    console.log('');
    
    if (response.success === 1) {
      console.log('🎉 푸시 전송 성공!');
      console.log(`   전송됨: ${response.success}개`);
      console.log(`   실패: ${response.failure}개`);
    } else {
      console.log('⚠️ 전송 실패');
      console.log(`   에러: ${JSON.stringify(response.results)}`);
    }
  });
});

req.on('error', (e) => {
  console.error('❌ 에러:', e.message);
});

req.write(postData);
req.end();
