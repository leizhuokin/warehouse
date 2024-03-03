package com.hnumi.commerce.mock.log.bean;

import com.hnumi.commerce.mock.common.util.*;
import com.hnumi.commerce.mock.log.config.AppConfig;
import com.hnumi.commerce.mock.log.enums.PageId;
import com.hnumi.commerce.mock.log.enums.DisplayType;
import com.hnumi.commerce.mock.log.enums.ItemType;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class AppPage {

     PageId last_page_id;
     PageId page_id;
     ItemType item_type;
     String item;
     Integer during_time;

     String extend1;

     String extend2;

     DisplayType source_type;



     public static AppPage build(AppCommon appCommon, PageId pageId, PageId lastPageId, Integer duringTime) {
          ItemType itemType = null;
          String item = null;
          DisplayType sourceType = null;
          RandomBox sourceTypeGroup = RandomBox.builder().add(DisplayType.query, AppConfig.sourceTypeRate[0]).add(DisplayType.promotion, AppConfig.sourceTypeRate[1]).add(DisplayType.recommend, AppConfig.sourceTypeRate[2]).add(DisplayType.activity, AppConfig.sourceTypeRate[3]).build();
          if (pageId != PageId.good_detail && pageId != PageId.good_spec && pageId != PageId.comment && pageId != PageId.comment_list) {
               if (pageId == PageId.good_list) {
                    itemType = ItemType.keyword;
                    item = (new RandomBox(AppConfig.searchKeywords)).getRandStringValue();
               } else if (pageId == PageId.trade || pageId == PageId.payment || pageId == PageId.payment_done) {
                    itemType = ItemType.sku_ids;
                    item = RandomNumString.getRandNumString(1, AppConfig.max_sku_id, RandomNum.getRandInt(1, 3), ",", false);
               }
          } else {
               sourceType = (DisplayType)sourceTypeGroup.getValue();
               itemType = ItemType.sku_id;
               Integer[] skuWeightFemale = AppConfig.skuWeightFemale;
               Integer[] skuWeightMale = AppConfig.skuWeightMale;
               RandomNumBuilder randomNumBuilderF = new RandomNumBuilder(1, 35, skuWeightFemale);
               RandomNumBuilder randomNumBuilderM = new RandomNumBuilder(1, 35, skuWeightMale);
               String tailNum = appCommon.getUid().substring(appCommon.getUid().length() - 1);
               if (Integer.parseInt(tailNum) % 2 == 1) {
                    item = randomNumBuilderM.getNum() + "";
               } else {
                    item = randomNumBuilderF.getNum() + "";
               }

               if (Integer.parseInt(tailNum) % 2 == 0 && Integer.parseInt(item) < 20) {
                    System.out.println(item);
               }
          }

          return new AppPage(lastPageId, pageId, itemType, item, duringTime, null, null, sourceType);
     }




}
