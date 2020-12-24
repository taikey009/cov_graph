# cov-graphs

* [新型コロナウイルス感染症に関するデータ【北海道】](https://www.harp.lg.jp/opendata/dataset/1369.html)
    * [陽性患者属性](https://www.harp.lg.jp/opendata/dataset/1369/resource/2828/patients.csv)

```bash
# 取得
wget https://www.harp.lg.jp/opendata/dataset/1369/resource/2828/patients.csv

# 変換 : 復帰改行削除 + SJIS -> UTF8
nkf -wd --overwrite patients.csv

# 変換 : CSV -> TSV
csvformat -T patients.csv > patients.tsv

# 集計
echo 'date,name,category,value' > summarized_patients.csv
./summarize_patients.awk -F"\t" patients.tsv | sort >> summarized_patients.csv
```

```bash
# リリース日
cat patients.tsv | awk -F"\t" 'NR>1 {print $2}' | sort -u

# 曜日
cat patients.tsv | awk -F"\t" 'NR>1 {print $3}' | sort -u

# 居住地
cat patients.tsv | awk -F"\t" 'NR>1 {print $4}' | sort -u

# 年代
cat patients.tsv | awk -F"\t" 'NR>1 {print $5}' | sort -u

# 性別
cat patients.tsv | awk -F"\t" 'NR>1 {print $6}' | sort -u

# 属性
cat patients.tsv | awk -F"\t" 'NR>1 {print $7}' | sort -u

# 備考
cat patients.tsv | awk -F"\t" 'NR>1 {print $8}' | sort -u

# 補足
cat patients.tsv | awk -F"\t" 'NR>1 {print $9}' | sort -u

# 退院
cat patients.tsv | awk -F"\t" 'NR>1 {print $10}' | sort -u

# 周囲の状況
cat patients.tsv | awk -F"\t" 'NR>1 {print $11}' | sort -u

# 濃厚接触者の状況
cat patients.tsv | awk -F"\t" 'NR>1 {print $12}' | sort -u

# age_group
cat patients.tsv | awk -F"\t" 'NR>1 {print $13}' | sort -u

# sex_en
cat patients.tsv | awk -F"\t" 'NR>1 {print $14}' | sort -u
```

### Docker

```bash
# 起動
docker-compose up
# http://localhost:8080/
```

----

### make

```
# 最新情報 取得
make data

# 起動
make dev
# see: http://localhost:3000/

# ビルド
make build

# デプロイ前 動作確認
make serve
# see: http://localhost:5000/

# デプロイ
make deploy
# see: https://cov-graphs.web.app/
```
