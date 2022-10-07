객체를 공유하는 함수가 있으며 이 함수를 사용하면 모든 사용자에게 똑같은 객체가 공유가 됩니다.

init함수를 보면 transfer의 share_object를 실행하고 있고 이를 통해서 누구나 해당 값에 접근해 수정 할 수 있습니다.

balance의 zero()라는 함수는 Balance 객체를 반환하는데
Balance는 이러한 형태를 가지고 있고, value는 0으로 반환됩니다.

```
struct Balance<phantom T> has store {
    value: u64
}
```

coin::take는 내부적으로 balance::split를 실행시키기 떄문에 shop.balance에서 amount만큼 빠져나가게 됩니다.
