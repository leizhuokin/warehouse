package com.hnumi.commerce.mock.log.util;

import com.hnumi.commerce.mock.log.config.AppConfig;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerRecord;

import java.util.Properties;

public class KafkaUtil {
    public static KafkaProducer<String, String> kafkaProducer = null;

    public KafkaUtil() {
    }

    public static KafkaProducer<String, String> createKafkaProducer() {
        Properties properties = new Properties();
        properties.put("bootstrap.servers", AppConfig.kafka_server);
        properties.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer");
        properties.put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer");
        KafkaProducer<String, String> producer = null;

        try {
            producer = new KafkaProducer(properties);
        } catch (Exception var3) {
            var3.printStackTrace();
        }

        return producer;
    }

    public static void send(String topic, String msg) {
        if (kafkaProducer == null) {
            kafkaProducer = createKafkaProducer();
        }
        kafkaProducer.send(new ProducerRecord(topic, msg));
    }
}
