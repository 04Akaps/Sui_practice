phantom에 대해서 알아야 합니다.

저도 저번에 어느정도 공부하다가 다시 하는거라 많이 부족하기 떄문에 다시 알아보았습니다.

https://github.com/move-language/move/blob/main/language/documentation/book/src/generics.md#phantom-type-parameters

phantom타입을 사용하기 위해서는 일단 다음과 같은 조건을 지켜야 합니다.

1. struct에서 선언되면, 내부에 있는 변수값에 phantom타입이 적힌 타입으로 할당 불가능

```
  struct Guardian<phantom  T : drop> has key, store {
        id : UID,
        test : T
    }
 -- 불가능
```

```
struct Currency1 {}
struct Currency2 {}

Currency == Currency1 or Currency2

struct Coin<Currency> has store {
        value: u64
}
```

이런식의 코드가 있다면 Coin이라는 구조체가 store를 가지고 있기 떄문에, Currency또한 store특성을 가지고 있지 않습니다.

이럴경우 이러한 문제가 발생 가능합니다.

- Coin<Currency1>이라는 구조체는 글로벌 저장소에 사용이 불가능 하게 될 것입니다.

물론 Currency에 store라는 특성을 부여하는 방식도 있지만 좋지 않은 방식입니다.

- Currency에 데이터를 저장하고 싶지 않기 떄문에

이러한 문제점을 해결하기 위해서 phantom을 사용합니다.

사용되지 않는 타입은 phantom으로 작성이 가능합니다.

예를들면 이와 같습니다.

```
struct S<T1, phantom T2> has copy { f: T1 }

struct HasCopy has copy {}
struct NoCopy {}

이 코드에서 S<HasCopy, NoCopy>를 생각해보면

S는 기본적으로 copy라는 특성을 가지고 잇기 떄문에 NoCopy는 copy라는 특성이 없어도 자동으로 copy특성을 가지게 될 것입니다.
```

**docs에 있는 내용을 나름대로 해석하며 진행해 보았지만 잘 이해는 되지 않아서.. 이후에 코드를 계속 작성해 가며 공부하도록 하겠습니다.**
