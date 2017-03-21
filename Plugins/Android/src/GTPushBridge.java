package com.getui.getuiunity;

import android.content.Context;

import com.igexin.sdk.GTIntentService;
import com.igexin.sdk.PushManager;
import com.igexin.sdk.Tag;
import com.unity3d.player.UnityPlayer;

/**
 * Created by zhourh on 2017/3/20.
 */

public class GTPushBridge {
  
    private static GTPushBridge  pushBridge = new GTPushBridge();

    public static String GAMA_OBJECT = "Main Camera";

    public static Context mContext;

    public static GTPushBridge getInstance(){
        return pushBridge;
    }

    public  void initPush(String gameObject){
        GAMA_OBJECT = gameObject;
        mContext = UnityPlayer.currentActivity.getApplicationContext();
        PushManager.getInstance().initialize(mContext, GTPushService.class);
        PushManager.getInstance().registerPushIntentService(mContext, GTPushIntentService.class);
    }

    public void setPushMode(boolean turnOn){
        if (turnOn){
            PushManager.getInstance().turnOnPush(mContext);
        }
        else{
            PushManager.getInstance().turnOffPush(mContext);
        }
    }

    public String getVersion(){
        return PushManager.getInstance().getVersion(mContext);
    }

    public String getClientId(){
        return PushManager.getInstance().getClientid(mContext);
    }

    public boolean isPushTurnOn(){
        return PushManager.getInstance().isPushTurnedOn(mContext);
    }

    public void turnOnPush(){
        PushManager.getInstance().turnOnPush(mContext);
    }

    public void turnOffPush(){
        PushManager.getInstance().turnOffPush(mContext);
    }

    public int setTag(String tagNames){
        String[] tagNameArray = tagNames.split(",");
        Tag[] tags;
        if (tagNames == null || tagNameArray.length <= 0){
            tags = null;
        }
        else{
            tags = new Tag[tagNameArray.length];
            for (int i = 0; i < tagNameArray.length; i++){
                Tag tag = new Tag();
                tag.setName(tagNameArray[i]);
                tags[i] = tag;
            }
        }

        return PushManager.getInstance().setTag(mContext, tags, "sn-default");
    }

    public boolean bindAlias(String alias){
        return PushManager.getInstance().bindAlias(mContext, alias);
    }

    public boolean unBindAlias(String alias){
        return PushManager.getInstance().unBindAlias(mContext, alias, true);
    }








}
