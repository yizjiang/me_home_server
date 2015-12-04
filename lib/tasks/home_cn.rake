# encoding: utf-8
namespace :cn do
  task :update => :environment do
     HomeCn.first.update_attributes(description: '欢迎来到这个宽敞、开放、充满光的家。提供最新的厨房和浴室，神话般的存储在大厅，效率。一个温和的观点和灿烂的太阳阳台一小口喝你的早晨咖啡，读你的下午书或放松的午睡。完美地坐落在圣卡洛斯市中心，漫步于晚餐或购物。',
                                    short_desc: '联排别墅/公寓,2房2浴,建筑面积93平方米,土地面积2144平方米',
                                    city: ' 红木城',
                                    price: '64.8万美元',
                                    indoor_size: '93平方米',
                                    lot_size: '2144平方米',
                                    unit_price: '6967美元/平方米'
       )
  end

  task :check  => :environment do
    p 'hello'.multibyte?
    p '红木'.multibyte?
  end

end
