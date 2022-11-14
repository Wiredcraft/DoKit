package com.didichuxing.doraemonkit.datapick;

import com.didichuxing.doraemonkit.util.FileIOUtils;
import com.didichuxing.doraemonkit.util.GsonUtils;
import com.didichuxing.doraemonkit.util.PathUtils;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

/**
 * ================================================
 * 作    者：jint（金台）
 * 版    本：1.0
 * 创建日期：2020-02-19-13:27
 * 描    述：dokit 埋点管理类
 * 修订历史：
 * ================================================
 */
public class DataPickManager {
    private static final String TAG = "DataPickManager";
    /**
     * 埋点集合
     */
    private List<DataPickBean.EventBean> events = new ArrayList<>();

    private DataPickBean dataPickBean = new DataPickBean();

    private static class Holder {
        private static DataPickManager INSTANCE = new DataPickManager();
    }

    public static DataPickManager getInstance() {
        return DataPickManager.Holder.INSTANCE;
    }

    private String filePath = PathUtils.getInternalAppFilesPath() + File.separator + "dokit.json";

    /**
     * 异常情况下保存到本地保存到本地
     */
    public void saveData2Local() {
        if (events == null || events.size() == 0) {
            return;
        }
        dataPickBean.setEvents(events);
        //保存数据到本地
        FileIOUtils.writeFileFromString(filePath, GsonUtils.toJson(dataPickBean));
    }
}
