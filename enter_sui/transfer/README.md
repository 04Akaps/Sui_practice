함수 앞에 제네릭 타입을 쓰고 특성을 적는것은 T에 대한 제약입니다.

- https://move-book.com/advanced-topics/understanding-generics.html?highlight=%3CT,:,store%3E#constraints-to-check-abilities

해당 값에 대해서 어떠한 특성을 추가 할지를 지정하는 것으로

이후 함수에서 내부적으로 사용하는, 외부에서 들어오는 인자에 T 타입은 저러한 특징을 가지게 됩니다.

즉 create라는 함수는 store라는 특성을 가지고 있기 떄문에 content라는 변수는 store라는 특성을 가지게 됩니다.

wrapper에 굳이 store가 없어도 build하는데에는 문제가 없지만 특정 특성을 정해주고자 할떄에는 사용해야 합니다.
