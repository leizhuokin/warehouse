package com.hnumi.commerce.mock.log;

import com.alibaba.fastjson2.JSON;
import com.hnumi.commerce.mock.common.util.*;
import com.hnumi.commerce.mock.log.config.AppConfig;
import com.hnumi.commerce.mock.log.enums.PageId;
import com.hnumi.commerce.mock.log.bean.*;
import com.hnumi.commerce.mock.log.util.HttpUtil;
import com.hnumi.commerce.mock.log.util.KafkaUtil;
import com.hnumi.commerce.mock.log.util.LogUtil;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.EnumUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;

import java.util.*;

@Component
public class Mocker implements Runnable{
    private Long ts;

    @Autowired
    KafkaTemplate kafkaTemplate;

    public Mocker() {
    }

    public List<AppMain> doAppMock() {
        List<AppMain> logList = new ArrayList<>();
        Date curDate = ParamUtil.checkDate(AppConfig.mock_date);
        this.ts = curDate.getTime();
        AppMain.AppMainBuilder appMainBuilder = AppMain.builder();
        AppCommon appCommon = AppCommon.build();
        appMainBuilder.common(appCommon);
        appMainBuilder.checkError();
        AppStart appStart = (new AppStart.Builder()).build();
        appMainBuilder.start(appStart);
        appMainBuilder.ts(this.ts);
        logList.add(appMainBuilder.build());
        String jsonFile = ConfigUtil.loadJsonFile("path.json");
        List<Map> pathList = JSON.parseArray(jsonFile, Map.class);
        RandomBox.Builder<List> builder = RandomBox.builder();
        Iterator it = pathList.iterator();

        while(it.hasNext()) {
            Map map = (Map)it.next();
            List path = (List)map.get("path");
            Integer rate = (Integer)map.get("rate");
            builder.add(path, rate);
        }

        List chosenPath = builder.build().getRandomOpt().getValue();
        PageId lastPageId = null;

        for(Iterator it2 = chosenPath.iterator(); it2.hasNext(); this.ts = this.ts + 1000L) {
            Object o = it2.next();
            AppMain.AppMainBuilder pageBuilder = AppMain.builder().common(appCommon);
            String path = (String)o;
            int pageDuringTime = RandomNum.getRandInt(1000, AppConfig.page_during_max_ms);
            PageId pageId = (PageId)EnumUtils.getEnum(PageId.class, path);
            AppPage page = AppPage.build(appCommon, pageId, lastPageId, pageDuringTime);
            if (pageId == null) {
                System.out.println();
            }

            pageBuilder.page(page);
            lastPageId = page.getPage_id();
            List<AppAction> appActionList = AppAction.buildList(page, this.ts, pageDuringTime);
            if (appActionList.size() > 0) {
                pageBuilder.actions(appActionList);
            }

            List<AppDisplay> displayList = AppDisplay.buildList(page);
            if (displayList.size() > 0) {
                pageBuilder.displays(displayList);
            }

            pageBuilder.ts(this.ts);
            pageBuilder.checkError();
            logList.add(pageBuilder.build());
        }

        return logList;
    }

    public static void main(String[] args) {
        (new Mocker()).doAppMock();
    }

    @Override
    public void run() {
        List<AppMain> appMainList = this.doAppMock();
        Iterator it = appMainList.iterator();

        while(it.hasNext()) {
            AppMain appMain = (AppMain)it.next();
            if (AppConfig.mock_type.equals("log")) {
                LogUtil.log(appMain.toString());
            } else if (AppConfig.mock_type.equals("http")) {
                HttpUtil.get(appMain.toString());
            } else if (AppConfig.mock_type.equals("kafka")) {
                KafkaUtil.send(AppConfig.kafka_topic, appMain.toString());
            }

            try {
                Thread.sleep((long)AppConfig.log_sleep);
            } catch (InterruptedException var5) {
                var5.printStackTrace();
            }
        }

    }
}
