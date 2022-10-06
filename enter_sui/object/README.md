기본적인 struct형태는 어렵지 않습니다.

하지만 Sui 네트워크와 소통하기 위해서는 key특성이 필요하고 해당 Key특성을 유지하기 위해서는 고유한 id값이 필요합니다.

그러기 떄문에 id값은 항상 필드의 첫번쨰 값으로 들어가게 되고, UID라는 것을 활용합니다.

해당 UID에는 ID라는 struct를 담고 있고 ID에는 address 타입의 변수를 한개 들고 있으니 단순히 address를 의미한다고 생각하면 됩니다.