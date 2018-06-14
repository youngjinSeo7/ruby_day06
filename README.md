# 180614 Day6

- 오전 과제
  - ORM이란?



## Controller

- 역할?
  - 서비스 로직 을 가지고 있음
- 그동안 `app.rb`에서 작성했던 모든 내용이 `Controller`에 들어감
- `Controller`는 하나의 서비스에 대해서만 관련한다.
- `Controller`를 만들 때에는 `$ rails g controller 컨트롤러명`을 이용한다.

```command
$ rails g controller home
# app/controllers/home_controller.rb 파일 생성
      create  app/controllers/home_controller.rb
      invoke  erb
      create    app/views/home
      invoke  test_unit
      create    test/controllers/home_controller_test.rb
      invoke  helper
      create    app/helpers/home_helper.rb
      invoke    test_unit
      invoke  assets
      invoke    coffee
      create      app/assets/javascripts/home.coffee
      invoke    scss
      create      app/assets/stylesheets/home.scss
```

*app/controllers/home_controller.rb*

```ruby
class HomeController < ApplicationController
    #상단의 코드는 ApplicationController를 상속받는 코드
end
```

- `HomeController`를 만들면 *app/views* 하위에 컨트롤러 명과 일치하는 폴더가 생긴다.
- `HomeController`에서 액션(`def`)을 작성하면 해당 액션명과 일치하는 `view`파일을 *app/views/home* 폴더 밑에 작성한다.
- 사용자의 요청을 받는 url 설정은 *config/routes.rb*에서 한다.

> Rails에는 Development, Test, Production 환경(모드)가 있다.
>
> Development 환경에서는 변경사항이 자동적으로 확인되고, 모든 로그가 찍힌다.
>
> Production 환경에서는 변경사항도 자동적으로 저장되지 않고, 로그도 일부만.  `$ rails s` 로 서버를 실행하지 않는다.

#### 간단과제

- 점심메뉴를 랜덤으로 보여준다.
- 글자 + 이미지가 출력된다.
- 점심메뉴를 저장하는 변수는 `Hash`타입으로 한다.
  - @lunch = { "점심메뉴 이름" => "https://... .jpg"}
  - `Hash`에서 모든 key 값을 가져오는 메소드는 `.keys`이다.
- 요청은 `/lunch`로 받는다.



### Model

```command
$ rails g model 모델명
	  invoke  active_record
      create    db/migrate/20180614021008_create_users.rb
      create    app/models/user.rb
      invoke    test_unit
      create      test/models/user_test.rb
      create      test/fixtures/users.yml
      
# 실제 DB에 스키마 파일대로 적용하기
$ rake db:migrate
$ rake db:drop # DB 구조를 수정했을 경우 drop을 통해 DB를 날린다음 다시 migrate 해준다
```

- Rails는 ORM(Object Relation Mapper)을 기본적으로 장착하고 있음(Active Record)
- migrate 파일을 이용해서 DB의 구조를 잡아주고 명령어를 통해 실제 DB를 생성/변경 한다.
- Model 파일을 이용해서 DB에 있는 자료를 조작함

```ruby
> u1 = User.new # 빈 껍데기(테이블에서 row 한줄)를 만든다.
> u1.user_name = "haha" # 자료조작
> u1.password = "1234"
> u1.save # 실제 DB에 반영(저장)
> u1.password = "4321"
> u1.save
```



### User와 관련된 Model과 Controller 만들기

- 새로운 유저를 등록하고, 보여주는 컨트롤러와 모델을 만들어 봅시다.

```command
$ rails g model user
$ rails g controller user
```

*db/migrate/create_user.rb*

```ruby
class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      
      t.string "user_name"
      t.string "password"

      t.timestamps
    end
  end
end

```

*app/controllers/ user_controller*

```ruby
class UserController < ApplicationController
    def index
        @users = User.all
    end
    
    def new
    end
    
    def create
        u1 = User.new
        u1.user_name = params[:user_name]
        u1.password = params[:password]
        u1.save
        redirect_to "/user/#{u1.id}"
    end
    
    def show
        @user = User.find(params[:id])
    end
end

```

*config/routes.rb*

```ruby
Rails.application.routes.draw do
  get '/users' => 'user#index'
  get '/user/new' => 'user#new'
  get '/user/:id' => 'user#show'
  post '/user/create' => 'user#create'

end

```

- route를 등록할 때, wildcard 를 사용하면서 주의해야할 점이 있는데, `/user/new`의 new도 하나의 id로서 인식하게 될 수 있다는 점이다. 그래서 라우팅을 등록할 때 먼저 `/user/new`를 등록하고 그 후에 `/user/:id`를 등록하도록 한다.

*app/views/user/index.html.erb*

```html
<ul>
    <% @users.each do |user| %>
    <li><%= user.user_name %></li>
    <% end %>
</ul>
<a href="/user/new">새 회원등록</a>
```

*app/views/user/show.html.erb*

```html
<h1><%= @user.user_name %></h1>
<p><%= @user.password %></p>
<a href="/users">전체유저보기</a>
```

*app/views/user/new.html.erb*

```html
<form action="/user/create" method="POST">
    <input type="hidden" name="authenticity_token" value="<%= form_authenticity_token %>">
    <input type="text" name="user_name" placeholder="회원이름">
    <input type="password" name="password" placeholder="비밀번호">
    <input type="submit" value="등록하기">
</form>
```

- Rails에서는 POST 방식으로 요청을 보낼 때(새로운 정보가 등록되는 경우) 반드시 특정 토큰을 함께 보내게 되어 있다. 후에는 form_tag와 같은 특별한 레일즈 문법을 통해 쉽게 토큰을 보낼 수 있지만 지금 시점에서는 `form_authenticity_token`의 형식으로 토큰을 만들어 보내도록 한다.



#### 간단과제

- 그동안에 뽑혓던 내역을 저장해주는 로또번호 추천기
- `/lotto` => 새로 추천받은 번호를 출력
  - `a` 태그를 이용해서 새로운 번호를 발급
  - 새로 발급된 번호가 가장 마지막과 최 상단에 같이
  - 최 상단의 메시지는 `이번주 로또 번호는 [...] 입니다`
- `/lotto/new` => 신규 번호를 발급, 저장 후 `/lotto`로 리디렉션
- 모델명: Lotto
- 컨트롤러명: LottoController



### Lotto Controller, Lotto Model

```command
$ rails g controller lotto
Running via Spring preloader in process 6415
      create  app/controllers/lotto_controller.rb
      invoke  erb
      create    app/views/lotto
      invoke  test_unit
      create    test/controllers/lotto_controller_test.rb
      invoke  helper
      create    app/helpers/lotto_helper.rb
      invoke    test_unit
      invoke  assets
      invoke    coffee
      create      app/assets/javascripts/lotto.coffee
      invoke    scss
      create      app/assets/stylesheets/lotto.scss	
$ rails g model lotto
Running via Spring preloader in process 6404
      invoke  active_record
      create    db/migrate/20180614053528_create_lottos.rb
      create    app/models/lotto.rb
      invoke    test_unit
      create      test/models/lotto_test.rb
      create      test/fixtures/lottos.yml
```

1. 로또번호 정보를 저장할 `numbers` 컬럼을 추가한다.

*db/migrate/create_lottos.rb*

```ruby
class CreateLottos < ActiveRecord::Migration[5.0]
  def change
    create_table :lottos do |t|
      
      t.string "numbers"

      t.timestamps
    end
  end
end

```

> 하나의 기능을 구현하기 위해서 먼저 모델링(테이블 구조)에 대해서 지정하고 model에 relation을 지정한다. 그 이후에 어떤 컨트롤러를 사용할지 어떤 액션을 사용할지 routes 파일에 명시한 이후에 controller 파일을 작성하는 순서로 하는 것이 좋다. 정해진 것은 아니기에 본인이 편한 순서로 하면 된다.

2.  라우팅을 설정한다

*config/routes.rb*

```ruby
...
  get '/lotto' => 'lotto#index'
  get '/lotto/new' => 'lotto#new'
...
```

- `/lotto` 에서는 전체 리스트와 새로 등록된 번호를 볼 것이고, `/lotto/new`에서는 새로운 번호를 생성하고 저장한 이후에 전체 리스트를 보여주는 `/lotto`로 리디렉션 시켜준다.

3. controller logic

```ruby
class LottoController < ApplicationController
    def index
        @new_number = Lotto.last
        p @new_number.class
        @numbers = Lotto.all
    end
    def new
        number = (1..45).to_a.sample(6).sort.to_s
        lotto = Lotto.new
        lotto.numbers = number
        lotto.save
        redirect_to '/lotto'
    end
end
```

- index에서는 가장 최근에 저장된 번호를 불러온다. 여기에서 문제가 생길 수 있는 부분은 **처음**에는 아무런 정보도 저장되어 있지 않다는 점이다.

4. view

```html
<p>이번주 추천 숫자는 <%= @new_number.numbers %> 입니다. </p>
<a href="/lotto/new">새번호 발급받기</a>
<ul>
    <% @numbers.each do |number| %>
        <li><%= number.numbers %></li>
    <% end %>
</ul>
```

- 최초 접속시 `@new_number`가 `nil`이기 때문에 url로 `/lotto/new`로 접속을 우선 시도해서 하나의 정보를 가질 수 있게 하는 방법이 좋을 것 같다.

