## 사전 준비 작업
1. 사전에 폴더를 모두 다운로드를 합니다.
2. main.tf 파일은 dev 폴더에 저장을 하고, modules 폴더는 dev 폴더오 같은 위치에 있으면
   main.tf 경로 수정없이 사용이 가능합니다.

기본 디렉토리 예시
- tf \
  ㄴ dev 
      ㄴ main.tf \
  ㄴ module
      ㄴ ecs \
    ㄴ slb \
    ㄴ vpc \
    ㄴ rds \
    ㄴ sg
     

## Test 방법

1. Test를 하시려면, Config.tf 파일에 Access ID, Key를 기입하세요.
2. main_code.tf의 내용 중 내용이나 경로가 수정이 필요하면 수정합니다.
3. terrafrom plan 및 Apply로 생성을 합니다.
