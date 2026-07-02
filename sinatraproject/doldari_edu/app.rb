require 'sinatra'
require 'sinatra/reloader' if development?

# 외부 데이터베이스 파일 안전 경로
require_relative 'database/courses'
require_relative 'database/community'

# 서버 설정
set :views, File.dirname(__FILE__) + '/views'
set :public_folder, File.dirname(__FILE__) + '/public'
set :erb, :escape_html => true

# 메인 페이지
get '/' do
  @group_name = "Home"
  @list = []
  erb :index
end

# 연령별 강의 목록 페이지

get '/courses/:age_group' do
  @group = params[:age_group]
  @course_list = $courses_db[@group] || [] # 외부로 분리된 강의 DB 연동

  if @course_list.empty?
    "준비된 강의가 없습니다."
  else
    erb :course_list
  end
end

# 수강 신청 처리 로직
post '/apply' do
  @course_name = params[:course_name]
  @group_name = "신청이 완료되었습니다!"
  erb :apply_result
end

get '/course/:id' do
  target_id = params[:id].to_i
  @course = nil

# 모든 카테고리 순회하여 id를 가진 강의 탐색
  $courses_db.each do |category, list|
    found = list.find {|c| c[:id] == target_id}
    if found
      @course = found
      break
    end
  end

  if @course
    @group_name = @course[:category]
    erb :show
  else
    "강의를 찾을 수 없습니다."
  end
end

get '/search' do
  @query = params[:query]
  @results = []

  if @query && !@query.strip.empty?
  # 모든 카테고리를 순회하는 방식으로 검색어와 일치하는 강의를 찾도록 한다.
    $courses_db.each do |group, list|
      list.each do |course|
      # 이름(name) 혹은 설명(description)에 검색어가 포함되어 있는지 확인(대소문자 무시)
        if course[:name].include?(@query) || course[:description].include?(@query)
          @results << course
        end
      end
    end
  end

  @group_name = "검색 결과"
  erb :search_results
end

get '/about' do
  @group_name = "기관 소개"
  erb :about
end

get '/course' do
  @group_name = "강의 신청"
  erb :course_main
end

get '/notice' do
  @title = "알림마당"
  @categories = ["전체", "공지사항", "보도자료", "행사안내"]
  @current_category = params[:category] || "전체"
  @notices = $notices_db
  erb :notice
end

get '/community' do
  @group_name = "참여마당"
  # FAQ 데이터
  @faqs = $faqs_db
  erb :community
end

get '/community/free' do
  @title = "자유게시판"
  @post = $free_posts_db
  erb :free_board
end

get '/community/praise' do
  @title = "칭찬합시다"
  @praise_post = $praise_posts_db
  erb :praise_board
end

get '/community/inquiry' do
  @title = "1:1 상담문의"
  erb :inquiry_form
end

post '/community/inquiry' do
  redirect '/community'
end

get '/information' do
  @group_name = "정보공개"
  @public_info_categories = [
    {title: "행정정보공표", count: 12, icon: "📋"},
    {title: "예산집행 내역", count: 5, icon: "💰"},
    {title: "수의계약 현황", count: 8, icon: "🤝"},
    {title: "감사 결과", count: 3, icon: "🔍"}
  ]
  erb :information
end

get '/sitemap' do
  @group_name = "사이트맵"
  erb :sitemap
end

get '/login' do
  @group_name = "로그인"
  erb :login
end

get '/join' do
  @group_name = "회원가입"
  erb :join
end

get '/find_id' do
  @group_name = "아이디 찾기"
  erb :find_id
end

get '/find_pw' do
  @group_name = "비밀번호 찾기"
  erb :find_pw
end

post '/find_pw' do
  erb :find_pw_result
end

get '/press' do
  @title = "보도자료"
  @news_list = $press_list_db
  erb :press_list
end

get '/events' do
  @title = "행사안내"
  @event_list = $event_list_db
  erb :event_list
end
