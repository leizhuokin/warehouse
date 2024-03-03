package com.hnumi.commerce.mock.db.buffer;

import java.util.ArrayList;
import java.util.List;

public class BufferQueue<T> {
    private List<T> outputList = new ArrayList<>();
    private List<T> inputList = new ArrayList<>();

    public BufferQueue() {
    }

    public void push(T value) {
        synchronized(this.inputList) {
            this.inputList.add(value);
        }
    }

    public void pushAll(List<T> list) {
        synchronized(this.inputList) {
            this.inputList.addAll(list);
        }
    }

    public int getInputListSize() {
        synchronized(this.inputList) {
            return this.inputList.size();
        }
    }

    public List<T> getOutputList() {
        return this.outputList;
    }

    public void swap() {
        synchronized(this.inputList) {
            List<T> temp = this.outputList;
            this.outputList = this.inputList;
            this.inputList = temp;
            this.inputList.clear();
        }
    }
}