package sample;

import java.io.InputStream;
import java.util.Properties;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.io.BufferedInputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.File;

/**
 * The properties handler for this sample
 * With demo.properties in resources dir
 */
public class ConfigProperties {

    static Properties pp;

    static{
        pp = new Properties();
        InputStream fps = null;
        try {
            Path basepath = Paths.get(".").toAbsolutePath().normalize();
            fps = new BufferedInputStream(new FileInputStream(new File(basepath.toString()+"/resources/demo.properties")));
            pp.load(fps);
        } catch (IOException e) {
            System.out.print("Read config.properties file failed!");
            e.printStackTrace();
        }finally{
            try{
                if(fps!=null) fps.close();
            }catch(IOException e){
                System.out.print("Release the config file failed!");
                e.printStackTrace();
            }
        }
    }
    public static String values(String key) {
        String value = pp.getProperty(key);
        if (value != null) {
            return value.trim();
        } else {
            return null;
        }
    }
    public static String[] values_array(String key) {
        String value = pp.getProperty(key);
        if (value != null) {
            if (value.length() != 0) {
                return value.split (",", 0);
            }
        }
        return null;

    }
}