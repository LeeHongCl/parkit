import '../domain/destination.dart';

/// 실제 주소 검색 API 연동 전까지 사용하는 Mock 검색 대상 목록.
const List<Destination> mockSearchableDestinations = [
  Destination(
    name: '강남역',
    address: '서울 강남구 강남대로 396',
    latitude: 37.497952,
    longitude: 127.027619,
  ),
  Destination(
    name: '역삼역',
    address: '서울 강남구 테헤란로 131',
    latitude: 37.500622,
    longitude: 127.036456,
  ),
  Destination(
    name: '신논현역',
    address: '서울 강남구 강남대로 476',
    latitude: 37.504598,
    longitude: 127.025238,
  ),
  Destination(
    name: '언주역',
    address: '서울 강남구 언주로 지하 716',
    latitude: 37.503100,
    longitude: 127.034100,
  ),
  Destination(
    name: '강남파이낸스센터',
    address: '서울 강남구 테헤란로 152',
    latitude: 37.500600,
    longitude: 127.036500,
  ),
];
