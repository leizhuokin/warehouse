package com.hnumi.commerce.mock.common.util;

import org.apache.commons.lang3.RandomUtils;

import java.util.ArrayList;

public class RandomNumBuilder {
    ArrayList<Integer> numPool = null;

    public RandomNumBuilder(int fromNum, int toNum, Integer... weights) {
        this.numPool = new ArrayList<>();
        int index = 0;

        for(int num = fromNum; num <= toNum; ++num) {
            if (num < weights.length) {
                Integer weight = weights[index++];

                for(int k = 0; k < weight; ++k) {
                    this.numPool.add(num);
                }
            }
        }

    }

    public int getNum() {
        return (Integer)this.numPool.get(RandomUtils.nextInt(0, this.numPool.size()));
    }

}
