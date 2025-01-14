package com.didichuxing.doraemonkit.kit.health;

import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

import com.didichuxing.doraemonkit.R;
import com.didichuxing.doraemonkit.widget.dialog.DialogListener;
import com.didichuxing.doraemonkit.widget.dialog.DialogProvider;

/**
 * Created by jint on 2019/4/12
 * 完善健康体检用户信息dialog
 * @author jintai
 */
public class UserInfoDialogProvider<T> extends DialogProvider<T> {
    private TextView mPositive;
    private TextView mNegative;
    private TextView mClose;
    private EditText mCaseName;
    private EditText mUserName;

    UserInfoDialogProvider(T data, DialogListener listener) {
        super(data, listener);
    }

    @Override
    public int getLayoutId() {
        return R.layout.dk_dialog_userinfo;
    }

    @Override
    protected void findViews(View view) {
        mPositive = view.findViewById(R.id.positive);
        mNegative = view.findViewById(R.id.negative);
        mClose = view.findViewById(R.id.close);
        mCaseName = view.findViewById(R.id.edit_case_name);
        mUserName = view.findViewById(R.id.edit_user_name);
    }

    @Override
    protected void bindData(Object data) {

    }

    @Override
    protected View getPositiveView() {
        return mPositive;
    }

    @Override
    protected View getNegativeView() {
        return mNegative;
    }

    @Override
    protected View getCancelView() {
        return mClose;
    }

    @Override
    public boolean isCancellable() {
        return false;
    }
}
