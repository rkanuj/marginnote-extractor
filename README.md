从备份文件或生产数据库提取 MarginNote 4 的脑图大纲数据为 Obsidian 支持的 Markdown 格式。

- 软件需求：
    - 会 Python
        - 至少要知道怎么用 requirements.txt
    - 拥有 MarginNote 4 Mac 端应用 or iPad 端备份文件
        - 没有测试是否兼容 MarginNote 3 或更老版本的数据库
    - 使用 Obsidian
        - 脚本输出特化为 Obsidian Markdown 格式导出，使用了 Obsidian 特有语法 [^1]
    - macOS 系统
        - 没有测试导出 iPad 备份文件在 Windows 下的执行情况
- 使用步骤：
    - 准备一个 MarginNote 4 脑图卡片的 ID（`marginnote4app://note/xxx`）
        - 脑图关闭状态下复制的 ID 是文档笔记本中的卡片 ID，两者并不相同，还请注意
    - 根据提示将 ID 输入脚本
    - 脚本会提取该 ID 节点下的大纲树
    - 输出文本会自动拷贝到剪贴板
- 注意事项：
    - 该脚本是我个人工作流的一部分，主要目的是提取 MarginNote 阅读 PDF 的过程中整理的摘录到 Obsidian 便于后续引用，所以每条摘录都保留了卡片 ID 作为块 ID 和指向 MarginNote 的链接
        - 当然还有摘录 PDF 的页码用于在没有 MarginNote 时定位摘录
    - 建议的 MarginNote 摘录处理方式是「自动添加到脑图 + 脑图插入位置 - 分组（按文档目录）」
    - 因为一条摘录对应一条 Markdown 列表项，所以不支持多行摘录文本，会合并成一行
    - `- ["]` 和 `- [b]` 是 Obsidian Minimal 支持的样式 [^2]
    - 不支持除文档目录以外的卡片标题，非摘录含标题的卡片会作为一条目录列表项
    - 合并摘录因为数据库储存方式的原因，会丢失被合并节点的信息只保留文本，所以请保证每张卡片只包含一条摘录或图片
    - 脚本会将卡片之间的链接处理为 Obsidian 块引用，用卡片所属的文档笔记本作为链接的文件名，对于非摘录卡片会读取所属学习集名
    - 支持提取图片摘录，但图像会被转为 base64 编码嵌入文本，所以脚本会对图像进行可设定参数的压缩
    - 如果在输出中看到「No content」计数不为零，是因为 MarginNote 数据库没有更新摘录字段导致数据空白，解决方法是在执行脚本前通过手动更新卡片评论的方式刷新数据
        - 最简单的处理是全选卡片批量添加随便一个新标签再取消掉
    - 如果发现导出的摘录文本不是最新的，处理同上
- 免责：
    - 该脚本不包含数据更新操作，也不会逆流数据到 MarginNote
    - 脚本默认读取 Mac 端 MarginNote 4 的生产数据库，请保证理解每一行代码后再执行
    - 提供命令行构建脚本，有需要的话请自行打包可执行文件
    - 脚本无保修，仅供参考，自由取用
    - 有空会修我使用时发现的 Bug

| 参数                    | 默认值                              | 备注                               |
|-----------------------|----------------------------------|----------------------------------|
| `root_id`             | `None`                           | 命令行接受的第一个参数，需要导出的根节点卡片 ID        |
| `use_backup`          | `False`                          | 是否使用备份文件进行导出                     |
| `use_backup_pkg`      | `False`                          | 是否处理备份文件后缀为 `marginpkg`（单个学习集导出） |
| `backup_path`         | `'~/Downloads/MarginNoteBackup'` | 读取备份文件的目录路径                      |
| `image_quality`       | `25`                             | 图片摘录压缩的质量                        |
| `image_resize_factor` | `0.5`                            | 图片摘录缩放的比例                        |

[^1]: https://help.obsidian.md/Linking+notes+and+files/Internal+links#Link+to+a+block+in+a+note

[^2]: https://minimal.guide/checklists
