into_balance는 Coin객체를 삭제하고 안에 있는 balance값만을 반환

issue_title_deed는 ownable한 함수이다.

처음에 init을 할떄에 GovernmentCapability를 퍼블리셔에게 만들어 주었고,

이로인해 GovernmentCapability는 퍼블리셔만 가지고 있는 상태이다.

이떄 issue_title_deed함수 같은 경우에는 GovernmentCapability를 받고 있지만 사용은 하지 않기 떄문에 무조건 적으로 GovernmentCapability를 보내주기는 해야한다.

그러기 떄문에 ownable함수로 동작하게 된다.

- 사실 이런 느낌이지 않을까 정도로 이해를 하였다.. 어차피 나중에 트랜잭션 보면 저러한 값은 보이는 것이 아닌가 라는 생각이 들어서..
