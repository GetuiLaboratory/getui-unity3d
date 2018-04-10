package com.getui.getuiunity;

import com.igexin.sdk.GTIntentService;
import android.content.Context;


import com.igexin.sdk.GTIntentService;
import com.igexin.sdk.message.GTCmdMessage;
import com.igexin.sdk.message.GTNotificationMessage;
import com.igexin.sdk.message.GTTransmitMessage;
import com.unity3d.player.UnityPlayer;

import org.json.JSONException;
import org.json.JSONObject;
/**
 * Created by wanghaobo on 2018/3/20.
 */

public class GTPushIntentService extends GTIntentService {

    public GTPushIntentService() {

    }

    @Override
    public void onReceiveServicePid(Context context, int pid) {
    }

    @Override
    public void onReceiveMessageData(Context context, GTTransmitMessage msg) {
        try{
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("type", "payload");
            jsonObject.put("taskId", msg.getTaskId());
            jsonObject.put("msgId", msg.getMessageId());
            jsonObject.put("payload", new String(msg.getPayload()));
            UnityPlayer.UnitySendMessage(GTPushBridge.GAMA_OBJECT, "onReceiveMessage", jsonObject.toString());
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onReceiveClientId(Context context, String clientId) {
        UnityPlayer.UnitySendMessage(GTPushBridge.GAMA_OBJECT, "onReceiveClientId", clientId );
    }

    @Override
    public void onReceiveOnlineState(Context context, boolean online) {

    }

    @Override
    public void onReceiveCommandResult(Context context, GTCmdMessage cmdMessage) {
    }

    /*
     * 通知到达
     * 点击回调
     * 1.appid
     * 2.taskid
     * 3.messageid
     * 4.pkg
     * 5.cid
     * 6.title
     * 7.content
     */

    @Override
    public void onNotificationMessageArrived(Context context, GTNotificationMessage message) {
        try{
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("type","onNotificationMessageArrived");
            jsonObject.put("appId",message.getAppid());
            jsonObject.put("taskId",message.getTaskId());
            jsonObject.put("messageId",message.getMessageId());
            jsonObject.put("pkg",message.getPkgName());
            jsonObject.put("cid",message.getClientId());
            jsonObject.put("title",message.getTitle());
            jsonObject.put("content",message.getContent());
            UnityPlayer.UnitySendMessage(GTPushBridge.GAMA_OBJECT,"onNotificationMessageArrived",jsonObject.toString());

        } catch (JSONException e){
            e.printStackTrace();
        }
    }

    @Override
    public void onNotificationMessageClicked(Context context, GTNotificationMessage message) {
        try{
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("type","onNotificationMessageClicked");
            jsonObject.put("appId",message.getAppid());
            jsonObject.put("taskId",message.getTaskId());
            jsonObject.put("messageId",message.getMessageId());
            jsonObject.put("pkg",message.getPkgName());
            jsonObject.put("cid",message.getClientId());
            jsonObject.put("title",message.getTitle());
            jsonObject.put("content",message.getContent());
            UnityPlayer.UnitySendMessage(GTPushBridge.GAMA_OBJECT,"onNotificationMessageClicked",jsonObject.toString());

        } catch (JSONException e){
            e.printStackTrace();
        }
    }
}
