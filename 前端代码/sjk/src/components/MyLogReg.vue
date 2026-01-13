<template>
    <div class="container">
        <!-- 登录框 -->
        <div class="login_box" v-show="target == 1">
            <div class="head">
                中大外卖平台
            </div>
            <!-- 登录表单 -->
            <div>
                <el-form label-width="0" class="login_form" :model="login_form" :rules="login_rules" ref="login_form">
                    <!-- 用户名 -->
                    <el-form-item prop="userortel">
                        <el-input v-model="login_form.userortel" spellcheck="false" placeholder="手机号">
                        </el-input>
                    </el-form-item>
                    <!-- 密码 -->
                    <el-form-item prop="password">
                        <el-input v-model="login_form.password" show-password spellcheck="false" placeholder="密码">
                        </el-input>
                    </el-form-item>

                    <!-- 按钮 -->
                    <el-form-item class="btns">
                        <el-button type="primary" @click="llogin()">登录</el-button>
                    </el-form-item>
                </el-form>
                <div>
                    <div class="operate">
                        <span id="op1" @click="change(2)">注册</span>
                        <span id="op3" @click="change(4)">商家申请</span>
                        <span id="op2" @click="change(3)">忘记密码</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- 注册表单 -->
        <div class="reg_box" v-show="target == 2">
            <div class="head">
                中大外卖平台
            </div>
            <div>
                <el-form class="reg_form" :model="reg_form" :rules="reg_rules" ref="reg_form">
                    <!-- 用户名 -->
                    <el-form-item prop="username">
                        <el-input prefix-icon="iconfont icon-user" v-model="reg_form.username" spellcheck="false"
                            placeholder="用户名">
                        </el-input>
                    </el-form-item>
                    <!-- 密码 -->
                    <el-form-item prop="password">
                        <el-input prefix-icon="iconfont icon-password" v-model="reg_form.password" show-password
                            spellcheck="false" placeholder="密码(包含大小写字母、数字，长度在6-12之间)"></el-input>
                    </el-form-item>

                    <el-form-item prop="telephone">
                        <el-input prefix-icon="iconfont icon-password" v-model="reg_form.telephone" spellcheck="false"
                            placeholder="手机号码"></el-input>
                    </el-form-item>

                    <el-form-item prop="vercode">
                        <el-input v-model="reg_form.vercode" spellcheck="false" placeholder="验证码" style="width:230px">
                        </el-input>
                        <span style="width:120px;font-size: 16px;cursor: pointer;" @click="send_vercode_pre()"
                            v-show="getcode_show">
                            获取验证码
                        </span>

                        <span style="width:120px;font-size: 16px;cursor: pointer;" v-show="!getcode_show">
                            {{ time_count }}s后重新获取
                        </span>
                    </el-form-item>
                    <!-- 按钮 -->
                    <el-form-item class="btns">
                        <el-button type="primary" @click="zhuce()">注册</el-button>
                    </el-form-item>
                </el-form>
                <div>
                    <div>
                        <span @click="change(1)"
                            style="margin-left:210px;color: #000;opacity: .5;font-weight: 400;font-size: 16px;cursor:pointer;">登录</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- 找回密码 -->
        <div class="forget_box" v-show="target == 3">
            <div class="head">
                中大外卖平台
            </div>
            <div>
                <el-form class="reg_form" :model="findback_form" :rules="findback_rules" ref="findback_form">
                    <el-form-item prop="telephone">
                        <el-input prefix-icon="iconfont icon-password" v-model="reg_form.telephone" spellcheck="false"
                            placeholder="手机号码"></el-input>
                    </el-form-item>
                    <!-- 密码 -->
                    <el-form-item prop="password">
                        <el-input prefix-icon="iconfont icon-password" v-model="reg_form.password" show-password
                            spellcheck="false" placeholder="新密码"></el-input>
                    </el-form-item>

                    <el-form-item prop="vercode">
                        <el-input v-model="reg_form.vercode" spellcheck="false" placeholder="验证码" style="width:230px">
                        </el-input>
                        <span style="width:120px;font-size: 16px;cursor: pointer;" @click="send_vercode_pre()"
                            v-show="getcode_show">
                            获取验证码
                        </span>

                        <span style="width:120px;font-size: 16px;cursor: pointer;" v-show="!getcode_show">
                            {{ time_count }}s后重新获取
                        </span>
                    </el-form-item>
                    <!-- 按钮 -->
                    <el-form-item class="btns">
                        <el-button type="primary" @click="findback()">确认修改</el-button>
                    </el-form-item>
                </el-form>
                <div>
                    <div>
                        <span @click="change(1)"
                            style="margin-left:210px;color: #000;opacity: .5;font-weight: 400;font-size: 16px;cursor:pointer;">登录</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- 商家申请 -->
        <div class="shop_apply_box" v-show="target == 4">
            <div class="head">
                商家申请入驻
            </div>
            <div>
                <el-form class="apply_form" :model="apply_form" :rules="apply_rules" ref="apply_form">
                    <!-- 店铺名称 -->
                    <el-form-item prop="shop_name">
                        <el-input v-model="apply_form.shop_name" spellcheck="false"
                            placeholder="店铺名称">
                        </el-input>
                    </el-form-item>
                    <!-- 参考价格 -->
                    <el-form-item prop="price">
                        <el-input v-model="apply_form.price" spellcheck="false"
                            placeholder="参考价格（元）" type="number"></el-input>
                    </el-form-item>
                    <!-- 联系人 -->
                    <el-form-item prop="contact_name">
                        <el-input v-model="apply_form.contact_name" spellcheck="false"
                            placeholder="联系人姓名">
                        </el-input>
                    </el-form-item>
                    <!-- 联系电话 -->
                    <el-form-item prop="contact_phone">
                        <el-input v-model="apply_form.contact_phone" spellcheck="false"
                            placeholder="联系电话">
                        </el-input>
                    </el-form-item>
                    <!-- 店铺描述 -->
                    <el-form-item prop="description">
                        <el-input v-model="apply_form.description" type="textarea" :rows="3"    
                            placeholder="店铺简要描述">
                        </el-input>
                    </el-form-item>
                    <!-- 按钮 -->
                    <el-form-item class="btns">
                        <el-button type="primary" @click="submitApply()">提交申请</el-button>   
                    </el-form-item>
                </el-form>
                <div>
                    <div>
                        <span @click="change(1)"
                            style="margin-left:210px;color: #000;opacity: .5;font-weight: 400;font-size: 16px;cursor:pointer;">返回登录</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
export default {
    name: 'MyLogin',
    data() {
        var checkPassword = (rule, value, cb) => {
            const regPassword = /(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9]).{6,12}$/;
            if (regPassword.test(value)) {
                // 合法的手机号码
                return cb()
            }
            cb(new Error('包含大写字母、小写字母、数字，长度在6-12位之间'))
        };
        var checkMobile = (rule, value, cb) => {
            const regMobile = /^(0|86|17951)?(13[0-9]|15[012356789]|17[678]|18[0-9]|14[57])[0-9]{8}$/;
            if (regMobile.test(value)) {
                // 合法的手机号码
                return cb()
            }
            cb(new Error('手机号码格式不正确'))
        };
        var checkPrice = (rule, value, cb) => {
            if (!value) {
                return cb(new Error('请输入参考价格'))
            }
            if (!/^\d+$/.test(value)) {
                return cb(new Error('价格必须为数字'))
            }
            if (parseInt(value) <= 0) {
                return cb(new Error('价格必须大于0'))
            }
            cb()
        };
        return {
            getcode_show: true,
            time_count: '',
            timer: null,
            target: 1,
            login_form: {
                userortel: '',
                password: '',
            },
            reg_form: {
                username: '',
                password: '',
                telephone: '',
                vercode: ''
            },
            findback_form: {
                userortel: '',
                password: '',
                vercode:'',
            },
            // 添加商家申请表单数据
            apply_form: {
                shop_name: '',
                price: '',
                contact_name: '',
                contact_phone: '',
                description: ''
            },
            login_rules: {
                userortel: [
                    { required: true, message: '请输入电话', trigger: 'blur' }, 
                    { validator: checkMobile, trigger: 'blur' }
                ],
                password: [
                    { required: true, message: '请输入密码', trigger: 'blur' }
                ]
            },
            reg_rules: {
                username: [{ required: true, message: '请设置用户名', trigger: 'blur' }],
                password: [{ required: true, message: '请设置密码', trigger: 'blur' }, 
                          { validator: checkPassword, trigger: 'blur' }],
                telephone: [{ required: true, message: '请绑定手机号', trigger: 'blur' }, 
                           { validator: checkMobile, trigger: 'blur' }]
            },
            findback_rules: {
                userortel: [
                    { required: true, message: '请输入电话', trigger: 'blur' }, 
                    { validator: checkMobile, trigger: 'blur' }
                ],
                password: [
                    { required: true, message: '请输入密码', trigger: 'blur' }
                ]
            },
            // 添加商家申请表单验证规则
            apply_rules: {
                shop_name: [
                    { required: true, message: '请输入店铺名称', trigger: 'blur' }
                ],
                price: [
                    { required: true, message: '请输入参考价格', trigger: 'blur' },
                    { validator: checkPrice, trigger: 'blur' }
                ],
                contact_name: [
                    { required: true, message: '请输入联系人姓名', trigger: 'blur' }
                ],
                contact_phone: [
                    { required: true, message: '请输入联系电话', trigger: 'blur' },
                    { validator: checkMobile, trigger: 'blur' }
                ]
            }
        }
    },
    methods: {
        findback(){
            this.$refs.findback_form.validate(valid => {
                if (!valid)
                    return;
                else if(this.findback_form.vercode=='')
                    return;
                else{
                    console.log(111);
                }
            })
        },
        zhuce(){
            this.$refs.reg_form.validate(valid => {
                if (!valid)
                    return;
                else{
                    if(this.reg_form.vercode=='')
                        return;
                    else{
                        this.$axios.request({
                            method:'POST',
                            url:'/api/user/register/test',
                            data:{
                                username:this.reg_form.username,
                                password:this.reg_form.password,
                                vercode:this.reg_form.vercode,
                                telephone:this.reg_form.telephone
                            }
                        }).then((res)=>{
                            // console.log(res.status);
                            if(res.data.status==200)
                            {
                                this.$message({
                                message: '注册成功',
                                type: 'success'
                                })
                            this.target = 1;
                            // 页面变为登录页面
                            }else{
                                this.$message({
                                message: res.data.msg,
                                type: 'error'
                                })
                            
                            }
                            
                        })
                
                    }
                }
            })
        },
        change(id) {
            this.target = id;
        },
        llogin() {
            this.$refs.login_form.validate(valid => {
                if (!valid)
                    return;
                else //验证通过再发送请求
                    this.login();
            })
        },
        async login() {
            this.$axios.post("/api/user/login", this.login_form).then((res) => {
                console.log(res.status);
                //200登录成功
                if (res.data.code != 200) {
                    return this.$message({
                        message: res.data.msg,
                        type: 'error '
                    })
                } else {
                    this.$message({
                        message: '登录成功',
                        type: 'success'
                    })

                    window.localStorage.setItem("token", res.data.token);

                    if (res.data.role == 0)
                        this.$router.push('/user')
                    else
                        this.$router.push('/manage')
                }
            }).catch(() => {
                // console.log(res.response.data);
                this.$message({
                    message: "网络故障",
                    type: 'error'
                })
            })
        },

        // 获取验证码
        send_vercode_pre() {
            this.$refs.reg_form.validate(valid => {
                if (!valid) {
                    return;
                }
                else {
                    this.send_vercode();
                    // this.set_interval();
                }
            })
        },
        send_vercode() {
            this.$axios.request({
                method: 'POST',
                url: "/api/user/register/send_sms",
                data: {
                    telephone: this.reg_form.telephone
                }
            }).then(() => {
                this.$message({
                    message: '验证码发送成功',
                    type: 'success'
                })
            })
        },
        set_interval() {
            const TIME_COUNT = 60;
            if (!this.timer) {
                this.time_count = TIME_COUNT;
                this.getcode_show = false;
                this.timer = setInterval(() => {
                    if (this.time_count > 0 && this.time_count <= TIME_COUNT) {
                        this.time_count--;
                    } else {
                        this.getcode_show = true;
                        clearInterval(this.timer);
                        this.timer = null;
                    }
                }, 1000);
            }
        },

        // 添加商家申请提交方法
        submitApply() {
            this.$refs.apply_form.validate(valid => {
                if (!valid) return;
                
                this.$axios.request({
                    method: 'POST',
                    url: '/api/shop/apply',
                    data: this.apply_form
                }).then((res) => {
                    if (res.data.status == 200) {
                        this.$message({
                            message: '申请提交成功，等待管理员审核',
                            type: 'success'
                        });
                        this.target = 1; // 返回登录页面
                        // 清空表单
                        this.apply_form = {
                            shop_name: '',
                            price: '',
                            contact_name: '',
                            contact_phone: '',
                            description: ''
                        };
                        // 清除表单验证状态
                        if (this.$refs.apply_form) {
                            this.$refs.apply_form.clearValidate();
                        }
                    } else {
                        this.$message({
                            message: res.data.msg,
                            type: 'error'
                        });
                    }
                }).catch((error) => {
                    console.error('提交失败:', error);
                    this.$message({
                        message: '提交失败，请稍后重试',
                        type: 'error'
                    });
                });
            });
        }
    }
}
</script>

<style lang="less" scoped>
.container {
    background-color: #2b4b6b;
    height: 100%;
    width: 100%;
}

.head {
    text-align: center;
    height: 50px;
    line-height: 50px;
    font-size: larger;
}

.login_box {
    height: 300px;
    width: 450px;
    background-color: white;
    border-radius: 3px;
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
}

.reg_box {
    height: 400px;
    width: 450px;
    background-color: white;
    border-radius: 3px;
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
}

.forget_box {
    height: 350px;
    width: 450px;
    background-color: white;
    border-radius: 3px;
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
}

.input {
    width: 350px;
    height: 50px;
    margin-left: 50px;
}

.el-form-item {
    width: 350px;
    margin-left: 50px;
}

.btns {
    text-align: center;
}

.operate {
    text-align: center;
    color: #000;
    opacity: .5;
    font-weight: 400;
    font-size: 16px;
    margin-left: 28px;
}

.shop_apply_box {
    height: 450px;
    width: 450px;
    background-color: white;
    border-radius: 3px;
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
}

.apply_form .el-form-item {
    width: 350px;
    margin-left: 50px;
}

#op1 {
    padding-left: 15px;
    padding-right: 30px;
    border-right: 1px solid #bdb9b9;
    cursor: pointer;
}

#op2 {
    padding-left: 30px;
    padding-right: 15px;
    // border-right: 1px solid #e5e5e5;
    cursor: pointer;
}
</style>