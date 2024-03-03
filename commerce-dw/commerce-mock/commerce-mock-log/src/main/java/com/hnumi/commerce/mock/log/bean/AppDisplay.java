package com.hnumi.commerce.mock.log.bean;

import com.hnumi.commerce.mock.common.util.RandomBox;
import com.hnumi.commerce.mock.log.config.AppConfig;
import com.hnumi.commerce.mock.log.enums.PageId;
import com.hnumi.commerce.mock.common.util.RandomNum;
import com.hnumi.commerce.mock.log.enums.DisplayType;
import com.hnumi.commerce.mock.log.enums.ItemType;
import lombok.AllArgsConstructor;
import lombok.Data;

import java.util.ArrayList;
import java.util.List;

@Data
@AllArgsConstructor
public class AppDisplay {

    ItemType item_type;

    String item;

    DisplayType display_type;

    Integer order;

    Integer pos_id;

    public static List<AppDisplay> buildList(AppPage appPage) {
        List<AppDisplay> displayList = new ArrayList<>();
        int displayCount;
        int activityCount;
        int i;
        int skuId;
        if (appPage.page_id == PageId.home || appPage.page_id == PageId.discovery || appPage.page_id == PageId.category) {
            displayCount = RandomNum.getRandInt(1, AppConfig.max_activity_count);
            activityCount = RandomNum.getRandInt(1, AppConfig.max_pos_id);

            for (i = 1; i <= displayCount; ++i) {
                skuId = RandomNum.getRandInt(1, AppConfig.max_activity_count);
                AppDisplay appDisplay = new AppDisplay(ItemType.activity_id, skuId + "", DisplayType.activity, i, activityCount);
                displayList.add(appDisplay);
            }
        }

        if (appPage.page_id == PageId.good_detail || appPage.page_id == PageId.home || appPage.page_id == PageId.category || appPage.page_id == PageId.activity || appPage.page_id == PageId.good_spec || appPage.page_id == PageId.good_list || appPage.page_id == PageId.discovery) {
            displayCount = RandomNum.getRandInt(AppConfig.min_display_count, AppConfig.max_display_count);
            activityCount = displayList.size();

            for (i = 1 + activityCount; i <= displayCount + activityCount; ++i) {
                skuId = RandomNum.getRandInt(1, AppConfig.max_sku_id);
                int pos_id = RandomNum.getRandInt(1, AppConfig.max_pos_id);
                RandomBox<DisplayType> dispTypeGroup = RandomBox.builder().add(DisplayType.promotion, 30).add(DisplayType.query, 60).add(DisplayType.recommend, 10).build();
                DisplayType displayType = dispTypeGroup.getValue();
                AppDisplay appDisplay = new AppDisplay(ItemType.sku_id, skuId + "", displayType, i, pos_id);
                displayList.add(appDisplay);
            }
        }
        return displayList;
    }
}

