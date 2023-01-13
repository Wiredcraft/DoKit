package com.didichuxing.doraemonkit.kit.timecounter;

import android.os.Bundle;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.view.View;

import com.didichuxing.doraemonkit.R;
import com.didichuxing.doraemonkit.database.Counter;
import com.didichuxing.doraemonkit.database.WclDao;
import com.didichuxing.doraemonkit.kit.core.DoKitViewManager;
import com.didichuxing.doraemonkit.kit.timecounter.bean.CounterInfo;
import com.didichuxing.doraemonkit.kit.core.BaseFragment;
import com.didichuxing.doraemonkit.widget.recyclerview.DividerItemDecoration;
import com.didichuxing.doraemonkit.widget.titlebar.TitleBar;

import java.util.ArrayList;
import java.util.List;

/**
 * @desc: 跳转耗时历史记录列表
 */

public class TimeCounterListFragment extends BaseFragment {
    private static final String TAG = "TimeCounterListFragment";

    private RecyclerView mBlockList;
    private TimeCounterListAdapter mAdapter;
    private TitleBar mTitleBar;

    @Override
    protected int onRequestLayout() {
        return R.layout.dk_fragment_time_counter_list;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        initView();
        load();
        WclDao dao = DoKitViewManager.getINSTANCE().getCounterDb().wclDao();
        dao.getAllCounter();
    }


    private void initView() {
        mBlockList = findViewById(R.id.block_list);

        LinearLayoutManager layoutManager = new LinearLayoutManager(getContext());
        mBlockList.setLayoutManager(layoutManager);
        mAdapter = new TimeCounterListAdapter(getContext());
        mBlockList.setAdapter(mAdapter);
        DividerItemDecoration decoration = new DividerItemDecoration(DividerItemDecoration.VERTICAL);
        decoration.setDrawable(getResources().getDrawable(R.drawable.dk_divider));
        mBlockList.addItemDecoration(decoration);
        mTitleBar = findViewById(R.id.title_bar);
        mTitleBar.setOnTitleBarClickListener(new TitleBar.OnTitleBarClickListener() {
            @Override
            public void onLeftClick() {
                getActivity().onBackPressed();
            }

            @Override
            public void onRightClick() {

            }
        });
    }


    private void load() {
//        List<CounterInfo> infos = new ArrayList<>(TimeCounterManager.get().getHistory());
//        infos.add(0, TimeCounterManager.get().getAppSetupInfo());
        List<Counter> counters = DoKitViewManager.getINSTANCE().getCounterDb().wclDao().getAllCounter();
        List<CounterInfo> infos = new ArrayList<>();
        for (int i = 0; i < counters.size(); i++) {
            Counter c = counters.get(i);
            CounterInfo counterInfo = new CounterInfo();
            counterInfo.title = c.getTitle();
            counterInfo.time = c.getTime();
            counterInfo.launchCost = c.getLaunchCost();
            counterInfo.otherCost = c.getOtherCost();
            counterInfo.pauseCost = c.getPauseCost();
            counterInfo.renderCost = c.getRenderCost();
            counterInfo.totalCost = c.getTotalCost();
            counterInfo.type = c.getType();
            infos.add(counterInfo);
        }
        mAdapter.setData(infos);
    }


}
