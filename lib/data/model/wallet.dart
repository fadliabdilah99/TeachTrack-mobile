class Wallet {
  Wallet({
    this.id,
    this.nominal,
    this.jenis,
    this.keterangan,
  });

  int? id;
  int? nominal;
  String? jenis;
  String? keterangan;

  factory Wallet.fromjson(Map<String, dynamic> json) => Wallet(
        id: json["id"],
        nominal: json["nominal"],
        jenis: json["jenis"],
        keterangan: json["keterangan"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nominal": nominal,
        "jenis": jenis,
        "keterangan": keterangan,
      };

  static fromJson(e) {}
}
