#!/bin/bash

# FCM 테스트 푸시 전송 스크립트
# 사용법: ./test_fcm_push.sh jobs 2

# ⚠️ FCM 서버 키를 여기에 입력하세요!
FCM_SERVER_KEY="YOUR_FCM_SERVER_KEY_HERE"

DATA_TYPE=${1:-jobs}
VERSION=${2:-2}

if [ "$FCM_SERVER_KEY" = "YOUR_FCM_SERVER_KEY_HERE" ]; then
  echo "❌ FCM 서버 키를 설정해주세요!"
  echo "   Firebase Console → 프로젝트 설정 → 클라우드 메시징 → 서버 키"
  exit 1
fi

# 알림 메시지
if [ "$DATA_TYPE" = "jobs" ]; then
  TITLE="새로운 직업 추가!"
  BODY="새로운 직업이 추가되었습니다 🎮"
elif [ "$DATA_TYPE" = "party_templates" ]; then
  TITLE="새로운 템플릿 추가!"
  BODY="새로운 파티 템플릿이 추가되었습니다 🎉"
else
  TITLE="콘텐츠 업데이트!"
  BODY="새로운 콘텐츠가 업데이트되었습니다"
fi

UPDATED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "📤 FCM 푸시 전송 중..."
echo "   토픽: /topics/all_users"
echo "   데이터 타입: $DATA_TYPE"
echo "   버전: $VERSION"
echo ""

curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=$FCM_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"to\": \"/topics/all_users\",
    \"priority\": \"high\",
    \"content_available\": true,
    \"data\": {
      \"type\": \"data_update\",
      \"data_type\": \"$DATA_TYPE\",
      \"version\": \"$VERSION\",
      \"updated_at\": \"$UPDATED_AT\",
      \"click_action\": \"FLUTTER_NOTIFICATION_CLICK\"
    },
    \"notification\": {
      \"title\": \"$TITLE\",
      \"body\": \"$BODY\",
      \"sound\": \"default\",
      \"badge\": \"1\"
    },
    \"android\": {
      \"priority\": \"high\",
      \"notification\": {
        \"channel_id\": \"data_update_channel\",
        \"sound\": \"default\",
        \"priority\": \"high\"
      }
    },
    \"apns\": {
      \"headers\": {
        \"apns-priority\": \"10\"
      },
      \"payload\": {
        \"aps\": {
          \"alert\": {
            \"title\": \"$TITLE\",
            \"body\": \"$BODY\"
          },
          \"sound\": \"default\",
          \"badge\": 1,
          \"content-available\": 1
        }
      }
    }
  }" | python3 -m json.tool

echo ""
echo "✅ 전송 완료!"
