class HomeController < ApplicationController
    def index
        @msg = "나의 첫 레일즈"
    end
    
    def lotto
        @lotto = (1..45).to_a.sample(6).sort
    end
    
    def lunch
        @menu = {
            "떡볶이" => "https://png.pngtree.com/element_origin_min_pic/17/07/10/62849892d2475730a038cb134b125e1e.jpg",
            "돼지국밥" => "http://travel.chosun.com/site/data/img_dir/2011/07/11/2011071101128_0.jpg",
            "삼겹살" => "http://pds.joins.com/news/component/htmlphoto_mmdata/201702/27/117f5b49-1d09-4550-8ab7-87c0d82614de.jpg"
        }
        @lunch = @menu.keys.sample
    end
            
end
