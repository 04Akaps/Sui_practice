--- OwnerShip ---

battleAgainstBoss라는 함수에서 해당 NFT의 Owner인지는 체크하지 않아도 된다.

일단 기본적을 share_object라면 owner 체크를 해야 한다.

- changeMintingStatus 함수 체크

하지만 따로 이런 부분이 없다면 어차피 자동으로 Owner 체크가 된다.

- key특성 떄문이다.

그러기 떄문에 오히려 mintBoss라는 function을 확인해 보면 따로 Owner 체크를 하지 않는다.

- 왜냐하면 Ownership이라는 struct는 어차피 Owner인 계정에만 만들어져 있기 떄문이다.
