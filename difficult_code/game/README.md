일단 특이한 점은 move는 struct를 외부에 선언이 불가능 하다는 점 이였습니다..
그래서 원래는 파일은 따로 두어서 struct를 불러오는 형태로 사용을 하였지만 그냥 hero.move파일에 모두 옮겨 두었습니다.

- 상수값도 같았습니다..

- Invalid instantiation of '(game=0x0)::hero_box::GameAdmin'.
  All structs can only be constructed in the module in which they are declared
- Constants are internal to their module, and cannot can be accessed outside of their module

  -- 발생하였던 오류 입니다. --

freeze_object는 한번 설정되면 더이상 수정 및 transfer가 불가능 하게 만듭니다.
