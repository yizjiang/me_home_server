# encoding: utf-8
namespace :wechat do
  task :publish_menu => :environment do
    publish_menu(get_token)
  end

  task :publish_agent_menu => :environment do
    publish_menu(get_token(true), true)
  end

  def get_token(agent = false)
    if agent
      client_id = AGENT_WECHAT_CLIENTID
      client_secret = AGENT_WECHAT_CLIENTSECRET
    else
      client_id = WECHAT_CLIENTID
      client_secret = WECHAT_CLIENTSECRET
    end
    params = {grant_type: 'client_credential',
              appid: client_id,
              secret: client_secret}
    response = Typhoeus.get("https://api.weixin.qq.com/cgi-bin/token", params: params)
    JSON.parse(response.body)['access_token']
  end

  def publish_menu(access_token, agent = false)
    url = "https://api.weixin.qq.com/cgi-bin/menu/create?access_token=#{access_token}"
    body = if agent
             {
               button: [
                 {
                   name: '客户',
                   sub_button: [
                     {
                       name: '现有客户',
                       type: 'click',
                       key: 'my_client'
                     },

                     {
                       type: 'click',
                       name: '潜在买家',
                       key: 'buyer'
                     },

                     {
                       type: 'click',
                       name: '房屋咨询',
                       key: 'agent_request'
                     },

                     {
                       name: '普通咨询',
                       type: 'click',
                       key: 'cq'
                     }

                   ]

                 },

                 {
                   name: '主页管理',
                   sub_button: [
                     {
                       type: "click",
                       name: "基本信息",
                       key: "set_agent_page"
                     },

                     {
                       type: "click",
                       name: '推荐文章',
                       key: 'articles'
                     }
                   ]

                 },

                 {
                   name: '我',
                   sub_button: [
                     {
                       type: "click",
                       name: "觅家二维码",
                       key: "meejia_qr_code"
                     },

                     {
                       type: "click",
                       name: "我的房名牌",
                       key: "home_card"
                     },

                     {
                       type: "click",
                       name: "我的主页",
                       key: "agent_page"
                     },

                     {
                       type: "click",
                       name: "更改联系方式",
                       key: "update_qr"
                     },

                     {
                       type: "click",
                       name: "忘记密码",
                       key: "my_login"
                     }
                   ]

                 }]
             }
           else
             {
               button: [
                 {
                   name: '快速找房',
                   sub_button: [
                     {
                       name: '条件搜索',
                       type: 'click',
                       key: 's'
                     },

                     {
                       type: 'click',
                       name: '当前位置',
                       key: 'home_here'
                     },

                     {
                       type: 'view',
                       name: '湾区导购',
                       url: "#{CLIENT_HOST}/region_tutorial"
                     },

                     {
                       type: 'view',
                       name: '换房游戏',
                       url: "#{CLIENT_HOST}/game"
                     }
                   ]

                 },

                 {
                   name: '专业咨询',
                   sub_button: [
                     {
                       type: 'view',
                       name: '常见问题',
                       url: "#{CLIENT_HOST}/tutorial"
                     }
                     #
                     # {
                     #   type: "click",
                     #   name: "提问",
                     #   key: "q"
                     # },
                     #
                     # {
                     #   name: '购房经纪人',
                     #   type: 'click',
                     #   key: 'a'
                     # },
                     #
                     # {
                     #   type: "click",
                     #   name: "贷款经纪人",
                     #   key: "l"
                     # }
                   ]

                 },

                 {
                   name: "我的觅家",
                   sub_button: [
                     {
                       type: "click",
                       name: "红心房源",
                       key: "fav"
                     },

                     {
                       type: "click",
                       name: "更新条件搜索",
                       key: "u"
                     },

                     # {
                     #   type: "click",
                     #   name: "忘记密码",
                     #   key: "my_login"
                     # },

                     {
                       type: "click",
                       name: "我的经纪人",
                       key: "my_agent"
                     },

                     {
                       type: "click",
                       name: "我的二维码",
                       key: "update_qr"
                     }

                   ]}
               ]
             }
           end

    response = Typhoeus.post(url, body: body.to_json)
    p response.body
  end

end
