// BirdSearchPage.ets
import router from '@ohos.router'
import promptAction from '@ohos.promptAction'

interface Bird {
  id: number
  nameZh: string        // 中文名
  nameLatin: string     // 拉丁名
  thumb: string         // 缩略图 url
  tags: string[]        // 核心标签，如“雀形目·林栖”
}

@Entry
@Component
struct BirdSearchPage {
  // 搜索条件
  @State keyword: string = ''           // 名称模糊词
  @State family: string = ''            // 科属
  @State habitat: string = ''           // 栖息地
  @State voice: string = ''             // 叫声特征
  @State historyList: string[] = []     // 历史记录
  @State hotList: string[] =           // 热门搜索词
    ['麻雀', '珠颈斑鸠', '红嘴蓝鹊', '白头鹎', '乌鸫']

  // 联想候选
  @State suggestList: string[] = []
  // 结果列表
  @State resultList: Bird[] = []

  // 模拟全量数据（仅示例，可替换为云端接口）
  private allBirds: Bird[] = [
    {id:1, nameZh:'麻雀', nameLatin:'Passer montanus', thumb:'', tags:['雀形目','村落']},
    {id:2, nameZh:'珠颈斑鸠', nameLatin:'Spilopelia chinensis', thumb:'', tags:['鸽形目','林地']},
    {id:3, nameZh:'红嘴蓝鹊', nameLatin:'Urocissa erythrorhyncha', thumb:'', tags:['雀形目','林栖']},
    {id:4, nameZh:'白头鹎', nameLatin:'Pycnonotus sinensis', thumb:'', tags:['雀形目','灌丛']},
    {id:5, nameZh:'乌鸫', nameLatin:'Turdus mandarinus', thumb:'', tags:['雀形目','公园']},
  ]

  // 生命周期
  onPageShow(){
    // 可从本地存储读取历史
    this.historyList = ['麻雀','乌鸫']
  }

  // 联想输入
  onKeywordChange(val: string){
    this.keyword = val
    if(val.length > 0){
      // 简单前缀匹配
      this.suggestList = this.allBirds
        .map(b=>b.nameZh)
        .filter(name => name.indexOf(val) === 0)
    }else{
      this.suggestList = []
    }
  }

  // 点击联想或热门
  onTagClick(text: string){
    this.keyword = text
    this.suggestList = []
    this.doSearch()
  }

  // 执行搜索
  doSearch(){
    if(!this.keyword && !this.family && !this.habitat && !this.voice){
      promptAction.showToast({message:'请至少输入一个条件'})
      return
    }
    // 记录历史
    if(this.keyword && this.historyList.indexOf(this.keyword) === -1){
      this.historyList.unshift(this.keyword)
    }
    // 多条件过滤
    this.resultList = this.allBirds.filter(b =>
    (this.keyword ? b.nameZh.indexOf(this.keyword) >= 0 : true) &&
      (this.family ? b.tags.some(t=>t.indexOf(this.family) >= 0) : true) &&
      (this.habitat ? b.tags.some(t=>t.indexOf(this.habitat) >= 0) : true) &&
      (this.voice ? false : true)   // 叫声特征暂缺数据
    )
  }

  // 跳转详情（仅传递 id）
  goDetail(bird: Bird){
    router.push({ url:'pages/BirdDetailPage', params:{id:bird.id} })
  }

  build() {
    Column(){
      // 顶部标题
      Row() {
        Image($r('app.media.ic_back'))   // 换成自己的箭头 png/svg
          .width(24)
          .height(24)
          .fillColor('#4CAF50')
          .onClick(() => router.replaceUrl({
            url: 'pages/HomePage'  // 直接跳转到你的首页
          }))
        Blank()
        Text('鸟类速查')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#4CAF50')
        Blank()
      }
      .width('100%')
      .padding(16)


        Column(){
          // 1. 搜索区
          Column(){
            // 名称模糊
            TextInput({placeholder:'中文名称/拉丁名', text:this.keyword})
              .onChange(val=>this.onKeywordChange(val))
              .width('100%')
              .backgroundColor('#F5F5F5')
              .borderRadius(12)
              .padding(8)

            // 联想列表
            if(this.suggestList.length > 0){
              Column(){
                ForEach(this.suggestList, (item:string)=>{
                  Row(){
                    Text(item).fontSize(14).fontColor('#666')
                  }
                  .width('100%')
                  .padding(8)
                  .onClick(()=>this.onTagClick(item))
                })
              }
              .width('100%')
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .padding(8)
              .margin({top:4})
            }

            // 科属/栖息地/叫声
            Row(){
              TextInput({placeholder:'科属',text:this.family})
                .onChange(val=>this.family=val)
                .layoutWeight(1)
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
                .padding(10)
              Blank().width(8)
              TextInput({placeholder:'栖息地',text:this.habitat})
                .onChange(val=>this.habitat=val)
                .layoutWeight(1)
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
                .padding(10)
            }
            .width('100%')
            .margin({top:12})

            Button('搜索')
              .width('100%')
              .height(44)
              .backgroundColor('#4CAF50')
              .borderRadius(8)
              .margin({top:12})
              .onClick(()=>this.doSearch())
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)

          // 2. 热门/历史
          Row(){
            Text('热门').fontSize(16).fontColor('#333').fontWeight(FontWeight.Medium)
            Blank()
            Text('历史').fontSize(16).fontColor('#333').fontWeight(FontWeight.Medium)
          }
          .width('100%')
          .padding({top:16,bottom:8})

          Row(){
            Flex({wrap:FlexWrap.Wrap}){
              ForEach(this.hotList, (hot:string)=>{
                Text(hot)
                  .fontSize(12)
                  .fontColor('#4CAF50')
                  .backgroundColor('#E8F5E9')
                  .borderRadius(4)
                  .padding({left:8,right:8,top:4,bottom:4})
                  .margin({right:8,bottom:8})
                  .onClick(()=>this.onTagClick(hot))
              })
            }
            .layoutWeight(1)

            Flex({wrap:FlexWrap.Wrap}){
              ForEach(this.historyList, (his:string)=>{
                Text(his)
                  .fontSize(12)
                  .fontColor('#666')
                  .backgroundColor('#F5F5F5')
                  .borderRadius(4)
                  .padding({left:8,right:8,top:4,bottom:4})
                  .margin({right:8,bottom:8})
                  .onClick(()=>this.onTagClick(his))
              })
            }
            .layoutWeight(1)
          }
          .width('100%')

          // 3. 结果列表
          if(this.resultList.length > 0){
            Column(){
              Text(`共 ${this.resultList.length} 条`).fontSize(14).fontColor('#999').padding({top:16,bottom:8})
              ForEach(this.resultList, (bird:Bird)=>{
                Row(){
                  // 缩略图
                  Stack(){
                    // 这里用本地占位，真实场景用 Image(bird.thumb)
                    Text(bird.nameZh.substr(0,1))
                      .fontSize(24)
                      .fontColor('#FFFFFF')
                  }
                  .width(56)
                  .height(56)
                  .borderRadius(28)
                  .backgroundColor('#4CAF50')
                  .alignContent(Alignment.Center)

                  Column(){
                    Text(bird.nameZh).fontSize(16).fontColor('#333').maxLines(1)
                    Text(bird.nameLatin).fontSize(12).fontColor('#999').maxLines(1)
                    Row(){
                      ForEach(bird.tags, (tag:string)=>{
                        Text(tag)
                          .fontSize(10)
                          .fontColor('#4CAF50')
                          .backgroundColor('#E8F5E9')
                          .borderRadius(2)
                          .padding({left:4,right:4,top:2,bottom:2})
                          .margin({right:4})
                      })
                    }
                    .margin({top:4})
                  }
                  .layoutWeight(1)
                  .padding({left:12})
                }
                .width('100%')
                .padding(12)
                .backgroundColor('#FFFFFF')
                .borderRadius(8)
                .margin({bottom:8})
                .onClick(()=>this.goDetail(bird))
              })
            }
            .width('100%')
            .padding({top:8})
          }
        }
        .padding({left:16,right:16,bottom:32})

      .layoutWeight(1)
    }
    .backgroundColor('#F5F5F5')
    .height('100%')
  }
}