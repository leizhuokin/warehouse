package com.hnumi.commerce.mock.common.util;

import lombok.Getter;

@Getter
public class RanOpt<T>{
    T value ;
    int weight;

    public RanOpt ( T value, int weight ){
        this.value=value ;
        this.weight=weight;
    }
}
