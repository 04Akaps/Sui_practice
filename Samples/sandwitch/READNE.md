coin과 balance타입을 맞추는 부분에서 애를 좀 먹었습니다...

아무래도 포인터 타입은 익숙하지가 않고, 메서드 마다 포인터를 받을떄도 있고 안받을떄도 있어서인지.. 조금 많이 헤맸던거 같습니다.

take에 다시 다루어 보자면 새로운 Coin이라는 구조체를 return시키게 되는데 해당 balance값에는 balance::split라는 함수가 동작을 합니다.

balance::split는 인자를 두개 받습니다.

a,b라고 한다고 가정을 하면 신기하게도 a에서 b를 제외 시키고 그 이후에 b를 Return합니다.
즉 저 코드를 보면 profits에서 amount를 뺴고 이후 coin이라는 구조체에는 amount라는 balance가 누적 되는 것 입니다.
그후 간단하게 transfer로 전송을 합니다.
