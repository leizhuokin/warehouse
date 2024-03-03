package com.hnumi.commerce.mock.log.bean;

import com.hnumi.commerce.mock.common.util.RandomBox;
import com.hnumi.commerce.mock.log.config.AppConfig;
import com.hnumi.commerce.mock.common.util.RandomNum;
import com.hnumi.commerce.mock.common.util.RandomOptionGroup;
import com.hnumi.commerce.mock.log.enums.ActionId;
import com.hnumi.commerce.mock.log.enums.ItemType;
import com.hnumi.commerce.mock.log.enums.PageId;
import lombok.Data;

import java.util.ArrayList;
import java.util.List;

@Data
public class AppAction {

    public AppAction(ActionId action_id, ItemType item_type, String item) {
        this.action_id = action_id;
        this.item_type = item_type;
        this.item = item;
    }

    private ActionId action_id;
    private ItemType item_type;
    private String item;
    private String extend1;
    private String extend2;
    private Long ts;


    public static List<AppAction> buildList(AppPage appPage, Long startTs, Integer duringTime) {
        List<AppAction> actionList = new ArrayList<>();
        Boolean ifFavor = RandomBox.builder().add(true, AppConfig.if_favor_rate).add(false, 100 - AppConfig.if_favor_rate).build().getRandBoolValue();
        Boolean ifCart = RandomBox.builder().add(true, AppConfig.if_cart_rate).add(false, 100 - AppConfig.if_cart_rate).build().getRandBoolValue();
        Boolean ifCartAddNum = RandomBox.builder().add(true, AppConfig.if_cart_add_num_rate).add(false, 100 - AppConfig.if_cart_add_num_rate).build().getRandBoolValue();
        Boolean ifCartMinusNum = RandomBox.builder().add(true, AppConfig.if_cart_minus_num_rate).add(false, 100 - AppConfig.if_cart_minus_num_rate).build().getRandBoolValue();
        Boolean ifCartRm = RandomBox.builder().add(true, AppConfig.if_cart_rm_rate).add(false, 100 - AppConfig.if_cart_rm_rate).build().getRandBoolValue();
        Boolean ifGetCouponRm = RandomBox.builder().add(true, AppConfig.if_get_coupon).add(false, 100 - AppConfig.if_get_coupon).build().getRandBoolValue();
        AppAction favorAction;
        int skuId;
        if (appPage.page_id == PageId.good_detail) {
            AppAction cartAction;
            if (ifFavor) {
                cartAction = new AppAction(ActionId.favor_add, appPage.item_type, appPage.item);
                actionList.add(cartAction);
            }

            if (ifCart) {
                cartAction = new AppAction(ActionId.cart_add, appPage.item_type, appPage.item);
                actionList.add(cartAction);
            }

            if (ifGetCouponRm) {
                skuId = RandomNum.getRandInt(1, AppConfig.max_coupon_id);
                favorAction = new AppAction(ActionId.get_coupon, ItemType.coupon_id, String.valueOf(skuId));
                actionList.add(favorAction);
            }
        } else if (appPage.page_id == PageId.cart) {
            if (ifCartAddNum) {
                skuId = RandomNum.getRandInt(1, AppConfig.max_sku_id);
                favorAction = new AppAction(ActionId.cart_add_num, ItemType.sku_id, skuId + "");
                actionList.add(favorAction);
            }

            if (ifCartMinusNum) {
                skuId = RandomNum.getRandInt(1, AppConfig.max_sku_id);
                favorAction = new AppAction(ActionId.cart_minus_num, ItemType.sku_id, skuId + "");
                actionList.add(favorAction);
            }

            if (ifCartRm) {
                skuId = RandomNum.getRandInt(1, AppConfig.max_sku_id);
                favorAction = new AppAction(ActionId.cart_remove, ItemType.sku_id, skuId + "");
                actionList.add(favorAction);
            }
        } else {
            Boolean ifFavorCancel;
            if (appPage.page_id == PageId.trade) {
                ifFavorCancel = RandomBox.builder().add(true, AppConfig.if_add_address).add(false, 100 - AppConfig.if_add_address).build().getRandBoolValue();
                if (ifFavorCancel) {
                    favorAction = new AppAction(ActionId.trade_add_address, (ItemType) null, (String) null);
                    actionList.add(favorAction);
                }
            } else if (appPage.page_id == PageId.favor) {
                ifFavorCancel = RandomBox.builder().add(true, AppConfig.if_favor_cancel_rate).add(false, 100 - AppConfig.if_favor_cancel_rate).build().getRandBoolValue();
                skuId = RandomNum.getRandInt(1, AppConfig.max_sku_id);

                for (int i = 0; i < 3; ++i) {
                    if (ifFavorCancel) {
                        AppAction appAction = new AppAction(ActionId.favor_canel, ItemType.sku_id, skuId + i + "");
                        actionList.add(appAction);
                    }
                }
            }
        }

        skuId = actionList.size();
        long avgActionTime = (duringTime / (skuId + 1));

        for (int i = 1; i <= actionList.size(); ++i) {
            AppAction appAction = actionList.get(i - 1);
            appAction.setTs(startTs + (long) i * avgActionTime);
        }

        return actionList;
    }
}
