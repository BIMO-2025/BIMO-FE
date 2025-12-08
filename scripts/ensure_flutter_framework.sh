#!/bin/bash
# Flutter.framework 보호 및 자동 복원 스크립트
# 이 스크립트는 빌드 전에 Flutter.framework가 존재하는지 확인하고, 없으면 복원합니다.

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FLUTTER_FRAMEWORK_PATH="${PROJECT_ROOT}/ios/Flutter/Flutter.framework"
RESTORE_SCRIPT="${PROJECT_ROOT}/ios/Flutter/restore_framework.sh"

# Flutter.framework가 존재하는지 확인
if [ ! -d "$FLUTTER_FRAMEWORK_PATH" ]; then
    echo "⚠️  Flutter.framework가 없습니다. 복원을 시도합니다..."
    
    if [ -f "$RESTORE_SCRIPT" ]; then
        bash "$RESTORE_SCRIPT"
    else
        echo "❌ 복원 스크립트를 찾을 수 없습니다: $RESTORE_SCRIPT"
        exit 1
    fi
    
    # 복원 후 다시 확인
    if [ ! -d "$FLUTTER_FRAMEWORK_PATH" ]; then
        echo "❌ Flutter.framework 복원 실패"
        exit 1
    fi
fi

echo "✅ Flutter.framework 확인 완료"


