package com.hnumi.commerce.mock.log.bean;

import com.hnumi.commerce.mock.common.util.RanOpt;
import com.hnumi.commerce.mock.common.util.RandomBox;
import com.hnumi.commerce.mock.common.util.RandomNum;
import com.hnumi.commerce.mock.common.util.RandomOptionGroup;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class AppStart   {

    private String entry;//入口：  安装后进入=install，  点击图标= icon，  点击通知= notice
    private Long open_ad_id;//开屏广告Id
    private Integer open_ad_ms;//开屏广告持续时间
    private Integer open_ad_skip_ms;//开屏广告点击掉过的时间  未点击为0
    private Integer loading_time;//加载时长：计算下拉开始到接口返回数据的时间，（开始加载报0，加载成功或加载失败才上报时间）


    public static class Builder {
        private String entry = (new RandomBox(new RanOpt[]{new RanOpt("install", 5), new RanOpt("icon", 75), new RanOpt("notice", 20)})).getRandStringValue();
        private Long open_ad_id = (long)RandomNum.getRandInt(1, 20) + 0L;
        private Integer open_ad_ms = RandomNum.getRandInt(1000, 10000);
        private Integer open_ad_skip_ms;
        private Integer loading_time;
        private Integer first_open;

        public Builder() {
            this.open_ad_skip_ms = RandomBox.builder().add(0, 50).add(RandomNum.getRandInt(1000, this.open_ad_ms), 50).build().getRandIntValue();
            this.loading_time = RandomNum.getRandInt(1000, 20000);
            this.first_open = RandomNum.getRandInt(0, 1);
        }

        public AppStart build() {
            return new AppStart(this.entry, this.open_ad_id, this.open_ad_ms, this.open_ad_skip_ms, this.loading_time);
        }
    }

}
