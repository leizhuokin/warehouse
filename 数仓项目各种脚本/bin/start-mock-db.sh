#!/bin/bash
source /etc/profile
#当前脚本所在目录
CURRENT_DIR=$(cd "$(dirname "$0")" || exit; pwd)
parent_dir=$CURRENT_DIR/../mock/db
cd "${parent_dir}" || exit
#获取当前日期
current_date=$(date +"%Y-%m-%d")
#参数变量
arg=""
function rand(){
  min=$1
  max=$(($2-${min}+1))
  num=$(date +%s%N)
  echo $((${num}%${max}+${min}))
}
if [ "$1" != "" ];then
  current_date=$1
  # current_date="--mock.date=$1"
fi
#生成用户数
#r=$(rand 100 1000)
#arg="${arg} --mock.user.count=${r}"
##生成男女比例
#r=$(rand 10 80)
#arg="${arg} --mock.user.male-rate=${r}"
##用户数据变化概率
#r=$(rand 10 50)
#arg="${arg} --mock.user.update-rate=${r}"
##收藏取消比例
#r=$(rand 5 30)
#arg="${arg} --mock.favor.cancel-rate=${r}"
##收藏数量
#r=$(rand 50 700)
#arg="${arg} --mock.favor.count=${r}"
##每个用户添加购物车的概率
#r=$(rand 5 40)
#arg="${arg} --mock.cart.user-rate=${r}"
##每次每个用户最多添加多少种商品进购物车
#r=$(rand 3 20)
#arg="${arg} --mock.cart.max-sku-count=${r}"
##每个商品最多买几个
#r=$(rand 2 20)
#arg="${arg} --mock.cart.max-sku-num=${r}"
##用户下单比例
#r=$(rand 10 50)
#arg="${arg} --mock.order.user-rate=${r}"
##用户从购物中购买商品比例
#r=$(rand 30 70)
#arg="${arg} --mock.order.sku-rate=${r}"
##支付比例
#r=$(rand 60 95)
#arg="${arg} --mock.payment.rate=${r}"
#echo "${arg}"
#生成用户数
user_count=$(rand 100 1000)
#arg="${arg} --mock.user.count=${r}"
##生成男女比例
user_male_rate=$(rand 10 80)
#arg="${arg} --mock.user.male-rate=${r}"
##用户数据变化概率
user_update_rate=$(rand 10 50)
#arg="${arg} --mock.user.update-rate=${r}"
##收藏取消比例
favor_cancel_rate=$(rand 5 30)
#arg="${arg} --mock.favor.cancel-rate=${r}"
##收藏数量
favor_count=$(rand 50 700)
#arg="${arg} --mock.favor.count=${r}"
##每个用户添加购物车的概率
cart_user_rate=$(rand 5 40)
#arg="${arg} --mock.cart.user-rate=${r}"
##每次每个用户最多添加多少种商品进购物车
cart_max_sku_count=$(rand 3 20)
#arg="${arg} --mock.cart.max-sku-count=${r}"
##每个商品最多买几个
cart_max_sku_num=$(rand 2 20)
#arg="${arg} --mock.cart.max-sku-num=${r}"
##用户下单比例
order_user_rate=$(rand 10 50)
#arg="${arg} --mock.order.user-rate=${r}"
##用户从购物中购买商品比例
order_sku_rate=$(rand 30 70)
#arg="${arg} --mock.order.sku-rate=${r}"
##支付比例
payment_rate=$(rand 60 95)
#arg="${arg} --mock.payment.rate=${r}"
#echo "${arg}"
nohup java -jar "${parent_dir}/commerce-mock-db-1.0.0.jar" --mock.date=${current_date} --mock.user.count=${user_count} --mock.user.male-rate=${user_male_rate} --mock.user.update-rate=${user_update_rate} --mock.favor.cancel-rate=${favor_cancel_rate} --mock.favor.count=${favor_count} --mock.cart.user-rate=${cart_user_rate} --mock.cart.max-sku-count=${cart_max_sku_count} --mock.cart.max-sku-num=${cart_max_sku_num} --mock.order.user-rate=${order_user_rate} --mock.order.sku-rate=${order_sku_rate} --mock.payment.rate=${payment_rate} > "${JOB_HOME}"/logs/mock-db.log 2>&1 &