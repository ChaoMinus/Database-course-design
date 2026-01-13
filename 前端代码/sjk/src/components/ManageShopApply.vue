<template>
    <div>
        <div style="margin-bottom: 20px;">
            <el-radio-group v-model="statusFilter" @change="getApplyList">
                <el-radio-button label="0">待审核</el-radio-button>
                <el-radio-button label="1">已通过</el-radio-button>
                <el-radio-button label="2">已拒绝</el-radio-button>
            </el-radio-group>
        </div>
        
        <el-table :data="tableData" style="width: 100%" height="500">
            <el-table-column prop="shop_name" label="店铺名称" width="150"></el-table-column>
            <el-table-column prop="price" label="价格" width="80"></el-table-column>
            <el-table-column prop="contact_name" label="联系人" width="100"></el-table-column>
            <el-table-column prop="contact_phone" label="联系电话" width="120"></el-table-column>
            <el-table-column prop="description" label="店铺描述"></el-table-column>
            <el-table-column prop="apply_time" label="申请时间" width="160"></el-table-column>
            <el-table-column prop="process_time" label="处理时间" width="160" v-if="statusFilter != '0'"></el-table-column>
            
            <el-table-column label="操作" width="150" v-if="statusFilter == '0'">
                <template slot-scope="scope">
                    <el-button type="success" size="small" @click="processApply(scope.row, 'approve')">通过</el-button>
                    <el-button type="danger" size="small" @click="processApply(scope.row, 'reject')">拒绝</el-button>
                </template>
            </el-table-column>
        </el-table>
    </div>
</template>

<script>
export default {
    data() {
        return {
            statusFilter: '0',
            tableData: []
        }
    },
    mounted() {
        this.getApplyList();
    },
    methods: {
        getApplyList() {
            this.$axios.request({
                method: 'GET',
                url: '/api/manager/shop_apply',
                params: {
                    status: this.statusFilter
                }
            }).then((res) => {
                if (res.data.status == 200) {
                    this.tableData = res.data.tabledata;
                }
            });
        },
        processApply(row, action) {
            let confirmText = action === 'approve' ? '确定通过此申请？' : '确定拒绝此申请？';
            let confirmType = action === 'approve' ? 'success' : 'warning';
            
            this.$confirm(confirmText, '提示', {
                confirmButtonText: '确定',
                cancelButtonText: '取消',
                type: confirmType
            }).then(() => {
                this.$axios.request({
                    method: 'POST',
                    url: '/api/manager/shop_apply/process',
                    data: {
                        apply_id: row.id,
                        action: action
                    }
                }).then((res) => {
                    if (res.data.status == 200) {
                        this.$message({
                            message: res.data.msg,
                            type: 'success'
                        });
                        this.getApplyList(); // 刷新列表
                    } else {
                        this.$message({
                            message: res.data.msg,
                            type: 'error'
                        });
                    }
                });
            }).catch(() => {});
        }
    }
}
</script>