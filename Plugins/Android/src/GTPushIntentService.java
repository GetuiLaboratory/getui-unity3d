package com.getui.getuiunity;

import android.content.Context;


import com.igexin.sdk.GTIntentService;
import com.igexin.sdk.message.GTCmdMessage;
import com.igexin.sdk.message.GTTransmitMessage;
import com.unity3d.player.UnityPlayer;

import org.json.JSONException;
import org.json.JSONObject;


/**
 * Created by zhourh on 2017/3/17.
 * 继承 GTIntentService 接收来自个推的消息, 所有消息在线程中回调, 如果注册了该服务, 则务必要在 AndroidManifest中声明, 否则无法接受消息<br>
 * onReceiveMessageData 处理透传消息<br>
 * onReceiveClientId 接收 cid <br>
 * onReceiveOnlineState cid 离线上线通知 <br>
 * onReceiveCommandResult 各种事件处理回执 <br>
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
}
