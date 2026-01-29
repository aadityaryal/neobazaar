class KycSubmitRequestModel {
  final String documentType;
  final String documentFrontUrl;
  final String? documentBackUrl;
  final String? selfieUrl;

  const KycSubmitRequestModel({
    required this.documentType,
    required this.documentFrontUrl,
    this.documentBackUrl,
    this.selfieUrl,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'documentType': documentType,
      'documentFrontUrl': documentFrontUrl,
      'documentBackUrl': documentBackUrl,
      'selfieUrl': selfieUrl,
    };
  }
}

class KycReviewRequestModel {
  final String decision;
  final String? note;

  const KycReviewRequestModel({required this.decision, this.note});

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'decision': decision, 'note': note};
  }
}
