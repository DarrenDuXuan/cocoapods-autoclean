# cocoapods-autoclean

# 背景
随着组件一直不断的增多和迭代，我们发现组件的缓存越来越大，可以达到几百G这么夸张，所以定时的清理不必要的缓存是有必要的

> 扩展阅读：[Cocoapods 缓存管理机制](https://du-xuansorganization.gitbook.io/cocoapods-huan-cun-guan-li-ji-zhi/)

## 技术方案
### cocoapods 插件方案

1. cocoapods install 流程
![image.png](https://github.com/DarrenDuXuan/cocoapods-autoclean/blob/main/img/cocoapods-work-flow.png)

2. 使用 cocoapods HooksManager 在上图的 post_install 阶段，注入我们的autoclean方法
```
Pod::HooksManager.register('cocoapods-autoclean', :post_install) do |context|
    AutocleanModule::Autocleaner.new(context).autoclean
end
```
3. 用户使用 pod install/pod update 完成后会自动触发我们的自动清理逻辑
### 清理方案
流程图![image.png](https://github.com/DarrenDuXuan/cocoapods-autoclean/blob/main/img/autoclean-work-flow.png)

### 使用

1. 安装cocoapods-autoclean插件
    * 使用 gemfile管理的工程，gemfile内新增依赖 cocoapods-autoclean
2. podfile 内新增 plugin "cocoapods-autoclean"
3. pod install 或者 pod update即可

> cocoapods 插件，如果 podfile 如果有需要使用 cocoapods HookManager 的 pre_install 和 post_install 则必须在 podfile 中申明 plugin 'cocoapods-xxx'
