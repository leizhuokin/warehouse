package com.hnumi.commerce.mock.common.util;

import java.util.Random;

public class RandomNum {
    public static int getRandInt(int fromNum, int toNum) {

        return fromNum + new Random().nextInt(toNum - fromNum + 1);
    }

    public static int getRandInt(int fromNum, int toNum, Long seed) {

        return fromNum + new Random(seed).nextInt(toNum - fromNum + 1);
    }
}

