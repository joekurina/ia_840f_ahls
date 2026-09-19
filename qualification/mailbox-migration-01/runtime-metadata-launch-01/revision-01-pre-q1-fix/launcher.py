"""Fixed metadata child launcher. Local preparation, NOT execution authorization."""
import base64
import hashlib
import json
import os
import select
import signal
import sys
import time

PYTHON = '/usr/bin/python3'
REAL_PYTHON = '/usr/bin/python3.9'
PYTHON_SHA = '7a95e551de45a54b3b6819d80e71a7262cd7138c2a4f1ec905b4cc8895a034c2'
COLLECTOR_SHA = '6a524fbb0793822b55ef41855ea1f97f5d1e7210c0783cee53a5176e810ff897'
COLLECTOR_LENGTH = 13851
COLLECTOR_B64 = 'IyEvdXNyL2Jpbi9lbnYgcHl0aG9uMwoiIiJSZWFkLW9ubHksIGZpeGVkLXNjb3BlIHJ1bnRpbWUgbWV0YWRhdGEgZGlhZ25vc3RpYzsgUHl0aG9uIDMuOSBzdGRsaWIuIiIiCmltcG9ydCBlcnJubwppbXBvcnQganNvbgppbXBvcnQgb3MKaW1wb3J0IHN0YXQKaW1wb3J0IHN5cwppbXBvcnQgdGltZQoKQ0FORElEQVRFUyA9ICgnL3VzcicsICcvYmluJywgJy9saWInLCAnL2xpYjY0JykKTU9VTlRJTkZPID0gJy9wcm9jL3NlbGYvbW91bnRpbmZvJwpNQVhfRU5UUklFUyA9IDI1MDAwMApNQVhfQllURVMgPSAxMDQ4NTc2ClNFQ09ORFMgPSA2MApUTVVYID0gJy90bXAvdG11eC0xMDAwL2RlZmF1bHQsNzgyOCw0JwoKCmNsYXNzIFN0b3AoRXhjZXB0aW9uKToKICAgIHBhc3MKCgpjbGFzcyBOYXRpdmU6CiAgICBjbG9jayA9IHN0YXRpY21ldGhvZCh0aW1lLm1vbm90b25pYykKICAgIGxzdGF0ID0gc3RhdGljbWV0aG9kKG9zLmxzdGF0KQogICAgcmVhZGxpbmsgPSBzdGF0aWNtZXRob2Qob3MucmVhZGxpbmspCiAgICBzY2FuZGlyID0gc3RhdGljbWV0aG9kKG9zLnNjYW5kaXIpCgogICAgZGVmIGlkZW50aXR5KHNlbGYpOgogICAgICAgICMgRG8gbm90IGludm9rZSBOU1MsIHRtdXgsIG9yIGFueSBvdGhlciBwcm9jZXNzIHRvIGluc3BlY3QgaWRlbnRpdHkuCiAgICAgICAgcmV0dXJuIGRpY3QoaG9zdD1vcy51bmFtZSgpLm5vZGVuYW1lLCB1aWQ9b3MuZ2V0dWlkKCksIGV1aWQ9b3MuZ2V0ZXVpZCgpLAogICAgICAgICAgICAgICAgICAgIGdpZD1vcy5nZXRnaWQoKSwgZWdpZD1vcy5nZXRlZ2lkKCksIGdyb3Vwcz1vcy5nZXRncm91cHMoKSwKICAgICAgICAgICAgICAgICAgICB1c2VyPW9zLmVudmlyb24uZ2V0KCdVU0VSJyksIGxvZ25hbWU9b3MuZW52aXJvbi5nZXQoJ0xPR05BTUUnKSwKICAgICAgICAgICAgICAgICAgICB0bXV4PW9zLmVudmlyb24uZ2V0KCdUTVVYJykpCgogICAgZGVmIG1vdW50X29wZW4oc2VsZik6CiAgICAgICAgcmV0dXJuIG9wZW4oTU9VTlRJTkZPLCAncmInLCBidWZmZXJpbmc9MCkKCgpkZWYgc2lnbmF0dXJlKHMpOgogICAgcmV0dXJuIChzLnN0X2Rldiwgcy5zdF9pbm8sIHMuc3RfbW9kZSwgcy5zdF9zaXplLCBzLnN0X210aW1lX25zLCBzLnN0X2N0aW1lX25zKQoKCmNsYXNzIENvbGxlY3RvcjoKICAgIGRlZiBfX2luaXRfXyhzZWxmLCBiYWNrZW5kKToKICAgICAgICBzZWxmLmIgPSBiYWNrZW5kCiAgICAgICAgc2VsZi5zdGFydCA9IGJhY2tlbmQuY2xvY2soKQogICAgICAgIHNlbGYuZGVhZGxpbmUgPSBzZWxmLnN0YXJ0ICsgU0VDT05EUwogICAgICAgIHNlbGYucGhhc2UgPSAnaWRlbnRpdHknCiAgICAgICAgc2VsZi5vcCA9ICdzdGFydCcKICAgICAgICBzZWxmLnBhdGggPSBOb25lCiAgICAgICAgc2VsZi5yb290ID0gTm9uZQogICAgICAgIHNlbGYucmVwb3J0ID0gZGljdChhdXRob3JpemF0aW9uPUZhbHNlLCByZWFkeV9mb3JfYnVpbGQ9RmFsc2UsIHZlbmRvcl9ydW49RmFsc2UsCiAgICAgICAgICAgICAgICAgICAgICAgICAgIGNvdW50cz1kaWN0KHZpc2l0ZWQ9MCwgZGlzY292ZXJlZD0wKSwgc2VsZWN0aW9uPVtdLAogICAgICAgICAgICAgICAgICAgICAgICAgICBndWFyZD0nbm90X2NoZWNrZWQnLCBsYXN0X2NvbXBsZXRlZD1Ob25lLCBjbG9zZV9lcnJvcnM9W10pCiAgICAgICAgc2VsZi5hY3RpdmUgPSBbXQoKICAgIGRlZiBsYWJlbChzZWxmLCBvcCwgcGF0aCk6CiAgICAgICAgc2VsZi5vcCwgc2VsZi5wYXRoID0gb3AsIHBhdGgKCiAgICBkZWYgY2hlY2soc2VsZik6CiAgICAgICAgaWYgc2VsZi5iLmNsb2NrKCkgPj0gc2VsZi5kZWFkbGluZToKICAgICAgICAgICAgcmFpc2UgU3RvcCgnZGVhZGxpbmUnKQoKICAgIGRlZiBjYWxsKHNlbGYsIG9wLCBwYXRoLCBmbiwgKmFyZ3MpOgogICAgICAgIHNlbGYubGFiZWwob3AsIHBhdGgpCiAgICAgICAgc2VsZi5jaGVjaygpCiAgICAgICAgdmFsdWUgPSBmbigqYXJncykKICAgICAgICBzZWxmLnJlcG9ydFsnbGFzdF9jb21wbGV0ZWQnXSA9IGRpY3Qob3BlcmF0aW9uPW9wLCBwYXRoPXBhdGgpCiAgICAgICAgIyBSZXNvdXJjZSBhY3F1aXNpdGlvbnMgbXVzdCB0cmFuc2ZlciBvd25lcnNoaXAgYmVmb3JlIHBvc3QtY2FsbCBjaGVja3MuCiAgICAgICAgaWYgb3Agbm90IGluICgnbW91bnRpbmZvLm9wZW4nLCAnc2NhbmRpci5vcGVuJyk6CiAgICAgICAgICAgIHNlbGYuY2hlY2soKQogICAgICAgIHJldHVybiB2YWx1ZQoKICAgIGRlZiBmYWlsdXJlKHNlbGYsIGV4Yyk6CiAgICAgICAgcmV0dXJuIGRpY3QocGhhc2U9c2VsZi5waGFzZSwgb3BlcmF0aW9uPXNlbGYub3AsIHBhdGg9c2VsZi5wYXRoLAogICAgICAgICAgICAgICAgICAgIGV4Y2VwdGlvbj10eXBlKGV4YykuX19uYW1lX18sIGVycm5vPWdldGF0dHIoZXhjLCAnZXJybm8nLCBOb25lKSwKICAgICAgICAgICAgICAgICAgICBmaWxlbmFtZT1nZXRhdHRyKGV4YywgJ2ZpbGVuYW1lJywgTm9uZSksCiAgICAgICAgICAgICAgICAgICAgZmlsZW5hbWUyPWdldGF0dHIoZXhjLCAnZmlsZW5hbWUyJywgTm9uZSksCiAgICAgICAgICAgICAgICAgICAgcmVhc29uPXN0cihleGMpIGlmIGlzaW5zdGFuY2UoZXhjLCBTdG9wKSBlbHNlIE5vbmUsCiAgICAgICAgICAgICAgICAgICAgc2VsZWN0ZWRfcm9vdD1zZWxmLnJvb3QsIGNvdW50cz1kaWN0KHNlbGYucmVwb3J0Wydjb3VudHMnXSksCiAgICAgICAgICAgICAgICAgICAgZWxhcHNlZD1zZWxmLmIuY2xvY2soKSAtIHNlbGYuc3RhcnQpCgogICAgZGVmIGNsb3NlKHNlbGYsIG9iaiwgb3AsIHBhdGgpOgogICAgICAgICMgQ2xlYW51cCBtdXN0IHN0aWxsIHJ1biBhZnRlciBkZWFkbGluZSBvciBwcmltYXJ5IGZhaWx1cmUuIE5ldmVyIHJldHJ5LgogICAgICAgIHNlbGYubGFiZWwob3AsIHBhdGgpCiAgICAgICAgdHJ5OgogICAgICAgICAgICBvYmouY2xvc2UoKQogICAgICAgICAgICBzZWxmLnJlcG9ydFsnbGFzdF9jb21wbGV0ZWQnXSA9IGRpY3Qob3BlcmF0aW9uPW9wLCBwYXRoPXBhdGgpCiAgICAgICAgZXhjZXB0IEV4Y2VwdGlvbiBhcyBleGM6CiAgICAgICAgICAgIHNlbGYucmVwb3J0WydjbG9zZV9lcnJvcnMnXS5hcHBlbmQoc2VsZi5mYWlsdXJlKGV4YykpCiAgICAgICAgICAgIGlmICd0ZXJtaW5hbCcgbm90IGluIHNlbGYucmVwb3J0OgogICAgICAgICAgICAgICAgc2VsZi5yZXBvcnRbJ3Rlcm1pbmFsJ10gPSBzZWxmLmZhaWx1cmUoZXhjKQoKICAgIGRlZiByZXNvbHZlKHNlbGYsIGNhbmRpZGF0ZSk6CiAgICAgICAgIyBPbmx5IG1ldGFkYXRhIG9mIGNvbXBvbmVudHMgbmVjZXNzYXJ5IHRvIHJlc29sdmUgdGhlc2UgZml4ZWQgY2FuZGlkYXRlcy4KICAgICAgICBwZW5kaW5nID0gY2FuZGlkYXRlLnNwbGl0KCcvJylbMTpdCiAgICAgICAgcGFydHMgPSBbXQogICAgICAgIGxpbmtzID0gc2V0KCkKICAgICAgICB3aGlsZSBwZW5kaW5nOgogICAgICAgICAgICBzZWxmLmNoZWNrKCkKICAgICAgICAgICAgcGFydCA9IHBlbmRpbmcucG9wKDApCiAgICAgICAgICAgIGlmIHBhcnQgaW4gKCcnLCAnLicpOgogICAgICAgICAgICAgICAgY29udGludWUKICAgICAgICAgICAgaWYgcGFydCA9PSAnLi4nOgogICAgICAgICAgICAgICAgcGFydHMgPSBwYXJ0c1s6LTFdCiAgICAgICAgICAgICAgICBjb250aW51ZQogICAgICAgICAgICBwYXRoID0gJy8nICsgJy8nLmpvaW4ocGFydHMgKyBbcGFydF0pCiAgICAgICAgICAgIHMgPSBzZWxmLmNhbGwoJ3Jlc29sdmUubHN0YXQnLCBwYXRoLCBzZWxmLmIubHN0YXQsIHBhdGgpCiAgICAgICAgICAgIGlmIHN0YXQuU19JU0xOSyhzLnN0X21vZGUpOgogICAgICAgICAgICAgICAgaWYgcGF0aCBpbiBsaW5rczoKICAgICAgICAgICAgICAgICAgICByYWlzZSBTdG9wKCdyZXNvbHV0aW9uX2N5Y2xlJykKICAgICAgICAgICAgICAgIGxpbmtzLmFkZChwYXRoKQogICAgICAgICAgICAgICAgdGFyZ2V0ID0gc2VsZi5jYWxsKCdyZXNvbHZlLnJlYWRsaW5rJywgcGF0aCwgc2VsZi5iLnJlYWRsaW5rLCBwYXRoKQogICAgICAgICAgICAgICAgYWdhaW4gPSBzZWxmLmNhbGwoJ3Jlc29sdmUucmVjaGVjaycsIHBhdGgsIHNlbGYuYi5sc3RhdCwgcGF0aCkKICAgICAgICAgICAgICAgIGlmIHNpZ25hdHVyZShzKSAhPSBzaWduYXR1cmUoYWdhaW4pOgogICAgICAgICAgICAgICAgICAgIHJhaXNlIFN0b3AoJ3Jlc29sdXRpb25fcmFjZScpCiAgICAgICAgICAgICAgICBpZiB0YXJnZXQuc3RhcnRzd2l0aCgnLycpOgogICAgICAgICAgICAgICAgICAgIHBhcnRzID0gW10KICAgICAgICAgICAgICAgIHBlbmRpbmcgPSB0YXJnZXQuc3BsaXQoJy8nKSArIHBlbmRpbmcKICAgICAgICAgICAgZWxzZToKICAgICAgICAgICAgICAgIGlmIHBlbmRpbmcgYW5kIG5vdCBzdGF0LlNfSVNESVIocy5zdF9tb2RlKToKICAgICAgICAgICAgICAgICAgICByYWlzZSBTdG9wKCdyZXNvbHV0aW9uX2NvbXBvbmVudF9ub3RfZGlyZWN0b3J5JykKICAgICAgICAgICAgICAgIHBhcnRzLmFwcGVuZChwYXJ0KQogICAgICAgIHJlc29sdmVkID0gJy8nICsgJy8nLmpvaW4ocGFydHMpCiAgICAgICAgcmV0dXJuIHJlc29sdmVkLCBzZWxmLmNhbGwoJ3F1YWxpZmljYXRpb24ubHN0YXQnLCByZXNvbHZlZCwgc2VsZi5iLmxzdGF0LCByZXNvbHZlZCkKCiAgICBkZWYgc2VsZWN0KHNlbGYpOgogICAgICAgIHNlbGYucGhhc2UgPSAnc2VsZWN0aW9uJwogICAgICAgIHJvb3RzID0gW10KICAgICAgICBpbml0aWFsX2NhbmRpZGF0ZXMgPSB7fQogICAgICAgIGZvciBjYW5kaWRhdGUgaW4gQ0FORElEQVRFUzoKICAgICAgICAgICAgcmVjb3JkID0gZGljdChjYW5kaWRhdGU9Y2FuZGlkYXRlKQogICAgICAgICAgICBzZWxmLnJlcG9ydFsnc2VsZWN0aW9uJ10uYXBwZW5kKHJlY29yZCkKICAgICAgICAgICAgdHJ5OgogICAgICAgICAgICAgICAgaW5pdGlhbCA9IHNlbGYuY2FsbCgnY2FuZGlkYXRlLmxzdGF0JywgY2FuZGlkYXRlLCBzZWxmLmIubHN0YXQsIGNhbmRpZGF0ZSkKICAgICAgICAgICAgZXhjZXB0IEZpbGVOb3RGb3VuZEVycm9yIGFzIGV4YzoKICAgICAgICAgICAgICAgIGlmIGNhbmRpZGF0ZSA9PSAnL3Vzcicgb3IgZXhjLmVycm5vICE9IGVycm5vLkVOT0VOVDoKICAgICAgICAgICAgICAgICAgICByYWlzZQogICAgICAgICAgICAgICAgcmVjb3JkLnVwZGF0ZShxdWFsaWZpZWQ9RmFsc2UsIGV4Y2x1c2lvbj0nYWJzZW50JywgZXJybm89ZXhjLmVycm5vKQogICAgICAgICAgICAgICAgY29udGludWUKICAgICAgICAgICAgaW5pdGlhbF9jYW5kaWRhdGVzW2NhbmRpZGF0ZV0gPSBpbml0aWFsCiAgICAgICAgYWxsb3dlZF9leGFjdCA9IHtwIGZvciBwLCBzIGluIGluaXRpYWxfY2FuZGlkYXRlcy5pdGVtcygpIGlmIHN0YXQuU19JU0RJUihzLnN0X21vZGUpfQogICAgICAgIGZvciByZWNvcmQgaW4gc2VsZi5yZXBvcnRbJ3NlbGVjdGlvbiddOgogICAgICAgICAgICBjYW5kaWRhdGUgPSByZWNvcmRbJ2NhbmRpZGF0ZSddCiAgICAgICAgICAgIGlmIGNhbmRpZGF0ZSBub3QgaW4gaW5pdGlhbF9jYW5kaWRhdGVzOgogICAgICAgICAgICAgICAgY29udGludWUKICAgICAgICAgICAgaW5pdGlhbCA9IGluaXRpYWxfY2FuZGlkYXRlc1tjYW5kaWRhdGVdCiAgICAgICAgICAgIHJlc29sdmVkLCBzID0gc2VsZi5yZXNvbHZlKGNhbmRpZGF0ZSkKICAgICAgICAgICAgcmVjb3JkLnVwZGF0ZShyZXNvbHZlZD1yZXNvbHZlZCwgcXVhbGlmaWVkPXN0YXQuU19JU0RJUihzLnN0X21vZGUpKQogICAgICAgICAgICBpZiBub3Qgc3RhdC5TX0lTRElSKHMuc3RfbW9kZSk6CiAgICAgICAgICAgICAgICBpZiBjYW5kaWRhdGUgIT0gJy91c3InIGFuZCBzdGF0LlNfSVNSRUcocy5zdF9tb2RlKToKICAgICAgICAgICAgICAgICAgICByZWNvcmRbJ2V4Y2x1c2lvbiddID0gJ25vdF9kaXJlY3RvcnknCiAgICAgICAgICAgICAgICAgICAgY29udGludWUKICAgICAgICAgICAgICAgIHJhaXNlIFN0b3AoJ2NhbmRpZGF0ZV9ub3RfZGlyZWN0b3J5X29yX3Vuc3VwcG9ydGVkX3R5cGUnKQogICAgICAgICAgICBpZiBub3QgKHJlc29sdmVkID09ICcvdXNyJyBvciByZXNvbHZlZC5zdGFydHN3aXRoKCcvdXNyLycpIG9yCiAgICAgICAgICAgICAgICAgICAgcmVzb2x2ZWQgaW4gYWxsb3dlZF9leGFjdCk6CiAgICAgICAgICAgICAgICByYWlzZSBTdG9wKCdyZXNvbHZlZF9yb290X291dHNpZGVfc2NvcGUnKQogICAgICAgICAgICBhZ2FpbiA9IHNlbGYuY2FsbCgnY2FuZGlkYXRlLnJlY2hlY2snLCBjYW5kaWRhdGUsIHNlbGYuYi5sc3RhdCwgY2FuZGlkYXRlKQogICAgICAgICAgICBpZiBzaWduYXR1cmUoaW5pdGlhbCkgIT0gc2lnbmF0dXJlKGFnYWluKToKICAgICAgICAgICAgICAgIHJhaXNlIFN0b3AoJ2NhbmRpZGF0ZV9yYWNlJykKICAgICAgICAgICAgIyBFeGFjdCBhbGlhcyBkZWR1cCwgcGx1cyBuZXN0ZWQgY292ZXJhZ2UgZGVkdXAgdG8gd2FsayBlYWNoIHBhdGggb25jZS4KICAgICAgICAgICAgcm9vdHMuYXBwZW5kKChyZXNvbHZlZCwgcykpCiAgICAgICAgcmVzdWx0ID0gW10KICAgICAgICBmb3IgcGF0aCwgcyBpbiByb290czoKICAgICAgICAgICAgaWYgYW55KHBhdGggPT0gcCBvciBwYXRoLnN0YXJ0c3dpdGgocCArICcvJykgZm9yIHAsIF8gaW4gcmVzdWx0KToKICAgICAgICAgICAgICAgIGNvbnRpbnVlCiAgICAgICAgICAgIHJlc3VsdCA9IFsocCwgeCkgZm9yIHAsIHggaW4gcmVzdWx0IGlmIG5vdCBwLnN0YXJ0c3dpdGgocGF0aCArICcvJyldCiAgICAgICAgICAgIHJlc3VsdC5hcHBlbmQoKHBhdGgsIHMpKQogICAgICAgIHNlbGYucmVwb3J0Wydyb290cyddID0gW3AgZm9yIHAsIF8gaW4gcmVzdWx0XQogICAgICAgIHJldHVybiByZXN1bHQKCiAgICBkZWYgbW91bnRfZ3VhcmQoc2VsZiwgcm9vdHMpOgogICAgICAgIHNlbGYucGhhc2UgPSAnbW91bnRfZ3VhcmQnCiAgICAgICAgaGFuZGxlID0gc2VsZi5jYWxsKCdtb3VudGluZm8ub3BlbicsIE1PVU5USU5GTywgc2VsZi5iLm1vdW50X29wZW4pCiAgICAgICAgdHJ5OgogICAgICAgICAgICBjaHVua3MgPSBbXQogICAgICAgICAgICBzaXplID0gMAogICAgICAgICAgICB3aGlsZSBzaXplIDwgTUFYX0JZVEVTOgogICAgICAgICAgICAgICAgY2h1bmsgPSBzZWxmLmNhbGwoJ21vdW50aW5mby5yZWFkJywgTU9VTlRJTkZPLCBoYW5kbGUucmVhZCwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIG1pbig2NTUzNiwgTUFYX0JZVEVTIC0gc2l6ZSkpCiAgICAgICAgICAgICAgICBpZiBub3QgY2h1bms6CiAgICAgICAgICAgICAgICAgICAgYnJlYWsKICAgICAgICAgICAgICAgIGNodW5rcy5hcHBlbmQoY2h1bmspCiAgICAgICAgICAgICAgICBzaXplICs9IGxlbihjaHVuaykKICAgICAgICAgICAgIyBOZXZlciByZWFkIGEgc2VudGluZWwgYnl0ZSBiZXlvbmQgdGhlIDEgTWlCIGJ1ZGdldC4KICAgICAgICAgICAgaWYgc2l6ZSA9PSBNQVhfQllURVM6CiAgICAgICAgICAgICAgICByYWlzZSBTdG9wKCdtb3VudGluZm9faW5wdXRfbGltaXRfbm9fcm9vbV90b19lc3RhYmxpc2hfZW9mJykKICAgICAgICAgICAgc2VsZi5sYWJlbCgnbW91bnRpbmZvLnBhcnNlJywgTU9VTlRJTkZPKQogICAgICAgICAgICBsaW5lcyA9IGInJy5qb2luKGNodW5rcykuZGVjb2RlKCd1dGYtOCcsICdzdHJpY3QnKS5zcGxpdGxpbmVzKCkKICAgICAgICAgICAgaWYgbm90IGxpbmVzOgogICAgICAgICAgICAgICAgcmFpc2UgU3RvcCgnbW91bnRpbmZvX3BhcnNlX2VtcHR5JykKICAgICAgICAgICAgZm9yIGxpbmUgaW4gbGluZXM6CiAgICAgICAgICAgICAgICBzZWxmLmNoZWNrKCkKICAgICAgICAgICAgICAgIGZpZWxkcyA9IGxpbmUuc3BsaXQoKQogICAgICAgICAgICAgICAgaWYgbGVuKGZpZWxkcykgPCAxMCBvciAnLScgbm90IGluIGZpZWxkc1s2Ol06CiAgICAgICAgICAgICAgICAgICAgcmFpc2UgU3RvcCgnbW91bnRpbmZvX3BhcnNlJykKICAgICAgICAgICAgICAgIHNlcGFyYXRvciA9IGZpZWxkcy5pbmRleCgnLScsIDYpCiAgICAgICAgICAgICAgICBpZiAoc2VwYXJhdG9yICsgNCAhPSBsZW4oZmllbGRzKSBvcgogICAgICAgICAgICAgICAgICAgICAgICBub3QgZmllbGRzWzBdLmlzZGlnaXQoKSBvciBub3QgZmllbGRzWzFdLmlzZGlnaXQoKSBvcgogICAgICAgICAgICAgICAgICAgICAgICBsZW4oZmllbGRzWzJdLnNwbGl0KCc6JykpICE9IDIgb3IKICAgICAgICAgICAgICAgICAgICAgICAgbm90IGFsbCh4LmlzZGlnaXQoKSBmb3IgeCBpbiBmaWVsZHNbMl0uc3BsaXQoJzonKSkpOgogICAgICAgICAgICAgICAgICAgIHJhaXNlIFN0b3AoJ21vdW50aW5mb19wYXJzZScpCiAgICAgICAgICAgICAgICB0YXJnZXQgPSBmaWVsZHNbNF0KICAgICAgICAgICAgICAgIGlmICdcXCcgaW4gdGFyZ2V0OgogICAgICAgICAgICAgICAgICAgIHJhaXNlIFN0b3AoJ2VzY2FwZWRfbW91bnRfdGFyZ2V0JykKICAgICAgICAgICAgICAgIGlmIG5vdCB0YXJnZXQuc3RhcnRzd2l0aCgnLycpIG9yIG9zLnBhdGgubm9ybXBhdGgodGFyZ2V0KSAhPSB0YXJnZXQ6CiAgICAgICAgICAgICAgICAgICAgcmFpc2UgU3RvcCgnbW91bnRpbmZvX3RhcmdldF9pbnZhbGlkJykKICAgICAgICAgICAgICAgIGlmIGFueSh0YXJnZXQgPT0gcCBvciB0YXJnZXQuc3RhcnRzd2l0aChwICsgJy8nKSBmb3IgcCwgXyBpbiByb290cyk6CiAgICAgICAgICAgICAgICAgICAgcmFpc2UgU3RvcCgnbW91bnRfYXRfb3JfYmVsb3dfcm9vdCcpCiAgICAgICAgICAgIHNlbGYucmVwb3J0WydndWFyZCddID0gJ3Bhc3NlZCcKICAgICAgICBleGNlcHQgRXhjZXB0aW9uIGFzIGV4YzoKICAgICAgICAgICAgc2VsZi5yZXBvcnRbJ3Rlcm1pbmFsJ10gPSBzZWxmLmZhaWx1cmUoZXhjKQogICAgICAgIGZpbmFsbHk6CiAgICAgICAgICAgIHNlbGYuY2xvc2UoaGFuZGxlLCAnbW91bnRpbmZvLmNsb3NlJywgTU9VTlRJTkZPKQogICAgICAgIGlmICd0ZXJtaW5hbCcgaW4gc2VsZi5yZXBvcnQ6CiAgICAgICAgICAgIHJhaXNlIFN0b3AoJ2FscmVhZHlfcmVjb3JkZWQnKQogICAgICAgIHNlbGYuY2hlY2soKQoKICAgIGRlZiBhbmNlc3RvcnMoc2VsZik6CiAgICAgICAgZm9yIHBhdGgsIGJlZm9yZSwgXyBpbiBzZWxmLmFjdGl2ZToKICAgICAgICAgICAgYWZ0ZXIgPSBzZWxmLmNhbGwoJ2RpcmVjdG9yeS5yZWNoZWNrJywgcGF0aCwgc2VsZi5iLmxzdGF0LCBwYXRoKQogICAgICAgICAgICBpZiBzaWduYXR1cmUoYmVmb3JlKSAhPSBzaWduYXR1cmUoYWZ0ZXIpOgogICAgICAgICAgICAgICAgcmFpc2UgU3RvcCgnZGlyZWN0b3J5X3JhY2UnKQoKICAgIGRlZiBhZG1pdChzZWxmLCBwYXRoKToKICAgICAgICBzZWxmLmxhYmVsKCdkaXNjb3ZlcicsIHBhdGgpCiAgICAgICAgc2VsZi5jaGVjaygpCiAgICAgICAgaWYgc2VsZi5yZXBvcnRbJ2NvdW50cyddWydkaXNjb3ZlcmVkJ10gPj0gTUFYX0VOVFJJRVM6CiAgICAgICAgICAgIHJhaXNlIFN0b3AoJ2Rpc2NvdmVyZWRfbGltaXQnKQogICAgICAgIHNlbGYucmVwb3J0Wydjb3VudHMnXVsnZGlzY292ZXJlZCddICs9IDEKCiAgICBkZWYgdmlzaXQoc2VsZiwgcGF0aCwgZXhwZWN0ZWQ9Tm9uZSk6CiAgICAgICAgc2VsZi5sYWJlbCgnbHN0YXQnLCBwYXRoKQogICAgICAgIHNlbGYuY2hlY2soKQogICAgICAgIGlmIHNlbGYucmVwb3J0Wydjb3VudHMnXVsndmlzaXRlZCddID49IE1BWF9FTlRSSUVTOgogICAgICAgICAgICByYWlzZSBTdG9wKCd2aXNpdGVkX2xpbWl0JykKICAgICAgICBzZWxmLmFuY2VzdG9ycygpCiAgICAgICAgcyA9IHNlbGYuY2FsbCgnbHN0YXQnLCBwYXRoLCBzZWxmLmIubHN0YXQsIHBhdGgpCiAgICAgICAgc2VsZi5yZXBvcnRbJ2NvdW50cyddWyd2aXNpdGVkJ10gKz0gMQogICAgICAgIGlmIGV4cGVjdGVkIGlzIG5vdCBOb25lIGFuZCBzaWduYXR1cmUocykgIT0gc2lnbmF0dXJlKGV4cGVjdGVkKToKICAgICAgICAgICAgcmFpc2UgU3RvcCgncm9vdF9yYWNlJykKICAgICAgICBpZiBub3QgKHN0YXQuU19JU0RJUihzLnN0X21vZGUpIG9yIHN0YXQuU19JU1JFRyhzLnN0X21vZGUpIG9yIHN0YXQuU19JU0xOSyhzLnN0X21vZGUpKToKICAgICAgICAgICAgcmFpc2UgU3RvcCgndW5zdXBwb3J0ZWRfdHlwZScpCiAgICAgICAgaWYgc3RhdC5TX0lTTE5LKHMuc3RfbW9kZSk6CiAgICAgICAgICAgIHNlbGYuY2FsbCgncmVhZGxpbmsnLCBwYXRoLCBzZWxmLmIucmVhZGxpbmssIHBhdGgpCiAgICAgICAgaWYgc3RhdC5TX0lTRElSKHMuc3RfbW9kZSk6CiAgICAgICAgICAgIGl0ZXJhdG9yID0gc2VsZi5jYWxsKCdzY2FuZGlyLm9wZW4nLCBwYXRoLCBzZWxmLmIuc2NhbmRpciwgcGF0aCkKICAgICAgICAgICAgIyBSZWdpc3RlciBpbW1lZGlhdGVseSBzbyBhbGwgc3Vic2VxdWVudCBmYWlsdXJlcyBjbG9zZSB0aGlzIGl0ZXJhdG9yLgogICAgICAgICAgICBzZWxmLmFjdGl2ZS5hcHBlbmQoKHBhdGgsIHMsIGl0ZXJhdG9yKSkKICAgICAgICBhZnRlciA9IHNlbGYuY2FsbCgnZW50cnkucmVjaGVjaycsIHBhdGgsIHNlbGYuYi5sc3RhdCwgcGF0aCkKICAgICAgICBpZiBzaWduYXR1cmUocykgIT0gc2lnbmF0dXJlKGFmdGVyKToKICAgICAgICAgICAgcmFpc2UgU3RvcCgnZW50cnlfcmFjZScpCiAgICAgICAgc2VsZi5hbmNlc3RvcnMoKQoKICAgIGRlZiB3YWxrKHNlbGYsIHJvb3RzKToKICAgICAgICBzZWxmLnBoYXNlID0gJ3RyYXZlcnNhbCcKICAgICAgICBmb3Igcm9vdCwgcyBpbiByb290czoKICAgICAgICAgICAgc2VsZi5yb290ID0gcm9vdAogICAgICAgICAgICBzZWxmLmFkbWl0KHJvb3QpCiAgICAgICAgICAgIHNlbGYudmlzaXQocm9vdCwgcykKICAgICAgICAgICAgd2hpbGUgc2VsZi5hY3RpdmU6CiAgICAgICAgICAgICAgICBzZWxmLmFuY2VzdG9ycygpCiAgICAgICAgICAgICAgICBwYXRoLCBiZWZvcmUsIGl0ZXJhdG9yID0gc2VsZi5hY3RpdmVbLTFdCiAgICAgICAgICAgICAgICB0cnk6CiAgICAgICAgICAgICAgICAgICAgZW50cnkgPSBzZWxmLmNhbGwoJ3NjYW5kaXIuaXRlcmF0ZScsIHBhdGgsIG5leHQsIGl0ZXJhdG9yKQogICAgICAgICAgICAgICAgZXhjZXB0IFN0b3BJdGVyYXRpb246CiAgICAgICAgICAgICAgICAgICAgc2VsZi5hbmNlc3RvcnMoKQogICAgICAgICAgICAgICAgICAgIHNlbGYuYWN0aXZlLnBvcCgpCiAgICAgICAgICAgICAgICAgICAgc2VsZi5jbG9zZShpdGVyYXRvciwgJ3NjYW5kaXIuY2xvc2UnLCBwYXRoKQogICAgICAgICAgICAgICAgICAgIGlmICd0ZXJtaW5hbCcgaW4gc2VsZi5yZXBvcnQ6CiAgICAgICAgICAgICAgICAgICAgICAgIHJhaXNlIFN0b3AoJ2FscmVhZHlfcmVjb3JkZWQnKQogICAgICAgICAgICAgICAgICAgIGNvbnRpbnVlCiAgICAgICAgICAgICAgICBuYW1lID0gZW50cnkubmFtZQogICAgICAgICAgICAgICAgaWYgbm90IGlzaW5zdGFuY2UobmFtZSwgc3RyKSBvciBuYW1lIGluICgnJywgJy4nLCAnLi4nKSBvciAnLycgaW4gbmFtZSBvciAnXHgwMCcgaW4gbmFtZToKICAgICAgICAgICAgICAgICAgICByYWlzZSBTdG9wKCdpbnZhbGlkX2RpcmVjdG9yeV9lbnRyeScpCiAgICAgICAgICAgICAgICBjaGlsZCA9IHBhdGggKyAnLycgKyBuYW1lCiAgICAgICAgICAgICAgICBzZWxmLmFkbWl0KGNoaWxkKQogICAgICAgICAgICAgICAgc2VsZi52aXNpdChjaGlsZCkKCiAgICBkZWYgcnVuKHNlbGYpOgogICAgICAgIHRyeToKICAgICAgICAgICAgaWRlbnRpdHkgPSBzZWxmLmNhbGwoJ2lkZW50aXR5JywgTm9uZSwgc2VsZi5iLmlkZW50aXR5KQogICAgICAgICAgICBzZWxmLnJlcG9ydFsnaWRlbnRpdHknXSA9IGlkZW50aXR5CiAgICAgICAgICAgIGlmIG5vdCAoaWRlbnRpdHlbJ2hvc3QnXSA9PSAnQWdpbGV4N1dvcmtzdGF0aW9uJyBhbmQKICAgICAgICAgICAgICAgICAgICBpZGVudGl0eVsndWlkJ10gPT0gaWRlbnRpdHlbJ2V1aWQnXSA9PSAxMDAwIGFuZAogICAgICAgICAgICAgICAgICAgIGlkZW50aXR5Wyd1c2VyJ10gPT0gaWRlbnRpdHlbJ2xvZ25hbWUnXSA9PSAndXdiX3N0dWRlbnQwMCcgYW5kCiAgICAgICAgICAgICAgICAgICAgaWRlbnRpdHlbJ3RtdXgnXSA9PSBUTVVYKToKICAgICAgICAgICAgICAgIHJhaXNlIFN0b3AoJ2lkZW50aXR5X29yX2NvbnRleHRfbWlzbWF0Y2gnKQogICAgICAgICAgICByb290cyA9IHNlbGYuc2VsZWN0KCkKICAgICAgICAgICAgc2VsZi5tb3VudF9ndWFyZChyb290cykKICAgICAgICAgICAgc2VsZi53YWxrKHJvb3RzKQogICAgICAgICAgICBzZWxmLmNoZWNrKCkKICAgICAgICAgICAgc2VsZi5yZXBvcnRbJ3Rlcm1pbmFsJ10gPSBkaWN0KHJlc3VsdD0nY29tcGxldGVkJykKICAgICAgICBleGNlcHQgRXhjZXB0aW9uIGFzIGV4YzoKICAgICAgICAgICAgaWYgJ3Rlcm1pbmFsJyBub3QgaW4gc2VsZi5yZXBvcnQ6CiAgICAgICAgICAgICAgICBzZWxmLnJlcG9ydFsndGVybWluYWwnXSA9IHNlbGYuZmFpbHVyZShleGMpCiAgICAgICAgZmluYWxseToKICAgICAgICAgICAgd2hpbGUgc2VsZi5hY3RpdmU6CiAgICAgICAgICAgICAgICBwYXRoLCBfLCBpdGVyYXRvciA9IHNlbGYuYWN0aXZlLnBvcCgpCiAgICAgICAgICAgICAgICBzZWxmLmNsb3NlKGl0ZXJhdG9yLCAnc2NhbmRpci5jbG9zZScsIHBhdGgpCiAgICAgICAgc2VsZi5yZXBvcnRbJ2VsYXBzZWQnXSA9IHNlbGYuYi5jbG9jaygpIC0gc2VsZi5zdGFydAogICAgICAgIHJldHVybiBzZWxmLnJlcG9ydAoKCmRlZiBlbmNvZGUocmVwb3J0KToKICAgIGRhdGEgPSAoanNvbi5kdW1wcyhyZXBvcnQsIGVuc3VyZV9hc2NpaT1UcnVlLCBzZXBhcmF0b3JzPSgnLCcsICc6JykpICsgJ1xuJykuZW5jb2RlKCdhc2NpaScpCiAgICBpZiBsZW4oZGF0YSkgPD0gTUFYX0JZVEVTOgogICAgICAgIHJldHVybiBkYXRhCiAgICAjIFJlamVjdCByYXRoZXIgdGhhbiBzaWxlbnRseSB0cnVuY2F0ZSBvciBlbWl0IGEgcGFydGlhbCBmaW5kaW5nLgogICAgZmFsbGJhY2sgPSBkaWN0KGF1dGhvcml6YXRpb249RmFsc2UsIHJlYWR5X2Zvcl9idWlsZD1GYWxzZSwgdmVuZG9yX3J1bj1GYWxzZSwKICAgICAgICAgICAgICAgICAgICB0ZXJtaW5hbD1kaWN0KHJlc3VsdD0nSU5DT01QTEVURScsIHJlYXNvbj0nb3V0cHV0X2xpbWl0JyksCiAgICAgICAgICAgICAgICAgICAgY291bnRzPXJlcG9ydFsnY291bnRzJ10sIGVsYXBzZWQ9cmVwb3J0WydlbGFwc2VkJ10sCiAgICAgICAgICAgICAgICAgICAgZXZpZGVuY2VfZW1pdHRlZD1GYWxzZSkKICAgIHJldHVybiAoanNvbi5kdW1wcyhmYWxsYmFjaywgc2VwYXJhdG9ycz0oJywnLCAnOicpKSArICdcbicpLmVuY29kZSgnYXNjaWknKQoKCmRlZiBtYWluKCk6CiAgICBydW5uZXIgPSBDb2xsZWN0b3IoTmF0aXZlKCkpCiAgICByZXBvcnQgPSBydW5uZXIucnVuKCkKICAgIGRhdGEgPSBlbmNvZGUocmVwb3J0KQogICAgaWYgcnVubmVyLmIuY2xvY2soKSA+PSBydW5uZXIuZGVhZGxpbmUgYW5kIHJlcG9ydFsndGVybWluYWwnXS5nZXQoJ3Jlc3VsdCcpID09ICdjb21wbGV0ZWQnOgogICAgICAgIHJ1bm5lci5sYWJlbCgncmVwb3J0LmVuY29kZScsIE5vbmUpCiAgICAgICAgcmVwb3J0Wyd0ZXJtaW5hbCddID0gcnVubmVyLmZhaWx1cmUoU3RvcCgnZGVhZGxpbmUnKSkKICAgICAgICByZXBvcnRbJ2VsYXBzZWQnXSA9IHJ1bm5lci5iLmNsb2NrKCkgLSBydW5uZXIuc3RhcnQKICAgICAgICBkYXRhID0gZW5jb2RlKHJlcG9ydCkKICAgIHN5cy5zdGRvdXQuYnVmZmVyLndyaXRlKGRhdGEpCiAgICBzeXMuc3Rkb3V0LmJ1ZmZlci5mbHVzaCgpCiAgICByZXR1cm4gMCBpZiBqc29uLmxvYWRzKGRhdGEpWyd0ZXJtaW5hbCddLmdldCgncmVzdWx0JykgPT0gJ2NvbXBsZXRlZCcgZWxzZSAxCgoKaWYgX19uYW1lX18gPT0gJ19fbWFpbl9fJzoKICAgIHN5cy5leGl0KG1haW4oKSkK'
CAP = 1048576
TERM_AT = 65.0
KILL_AT = 70.0
GATE_SECONDS = 5.0
OUTPUT_SECONDS = 5.0
ARGV = (PYTHON, '-I', '-B', '-S', '-')


def digest(data):
    return hashlib.sha256(data).hexdigest()


def source():
    data = base64.b64decode(COLLECTOR_B64, validate=True)
    if len(data) != COLLECTOR_LENGTH or digest(data) != COLLECTOR_SHA:
        raise RuntimeError('collector_binding')
    return data


def attest():
    if sys.argv != ['-']:
        raise RuntimeError('stdin_program_only_no_arguments')
    if (os.uname().nodename != 'Agilex7Workstation' or
            os.getuid() != 1000 or os.geteuid() != 1000 or
            os.environ.get('USER') != 'uwb_student00' or
            os.environ.get('LOGNAME') != 'uwb_student00' or
            os.environ.get('TMUX') != '/tmp/tmux-1000/default,7828,4' or
            os.environ.get('TMUX_PANE') != '%4' or os.getppid() != 25387):
        raise RuntimeError('identity_or_pane_parent_mismatch')
    if (sys.version_info[:2] != (3, 9) or
            not sys.flags.isolated or not sys.flags.no_site or
            not sys.dont_write_bytecode or
            os.path.realpath(PYTHON) != REAL_PYTHON or
            os.path.realpath(sys.executable) != REAL_PYTHON or
            os.path.realpath('/proc/self/exe') != REAL_PYTHON):
        raise RuntimeError('interpreter_identity')
    # Two exact files only; no enumeration. Executable changes after this check
    # remain an explicit trusted-host race, not a sandbox claim.
    for path in (REAL_PYTHON, '/proc/self/exe'):
        h = hashlib.sha256()
        with open(path, 'rb') as handle:
            for block in iter(lambda: handle.read(65536), b''):
                h.update(block)
        if h.hexdigest() != PYTHON_SHA:
            raise RuntimeError('interpreter_hash')


def pidfd_preflight():
    if not callable(getattr(os, 'pidfd_open', None)) or not callable(
            getattr(signal, 'pidfd_send_signal', None)):
        raise RuntimeError('pidfd_API_unavailable')
    # Probe actual kernel/policy support before creating the one child.
    fd = os.pidfd_open(os.getpid(), 0)
    try:
        signal.pidfd_send_signal(fd, 0, None, 0)
    finally:
        os.close(fd)


def due(elapsed, term_sent, kill_sent):
    # When scheduling is delayed past both thresholds, issue TERM then KILL.
    answer = []
    if elapsed >= TERM_AT and not term_sent:
        answer.append(signal.SIGTERM)
    if elapsed >= KILL_AT and not kill_sent:
        answer.append(signal.SIGKILL)
    return answer


def run_child(data):
    """Internal fixed-source path; tests replace source constants with inert code."""
    if len(data) != COLLECTOR_LENGTH or digest(data) != COLLECTOR_SHA:
        raise RuntimeError('collector_binding')
    pidfd_preflight()
    fds = set()
    pid = None
    pfd = None
    reaped = False
    stdout, stderr = bytearray(), bytearray()
    errors = []
    timed_out = False
    status = None
    start = time.monotonic()

    def pipe():
        pair = os.pipe2(os.O_CLOEXEC)
        fds.update(pair)
        return pair

    def close(fd):
        if fd in fds:
            fds.remove(fd)
            os.close(fd)

    def send(sig):
        try:
            signal.pidfd_send_signal(pfd, sig, None, 0)
        except ProcessLookupError:
            pass  # Already exited; still reap only our unreaped direct child.

    try:
        ir, iw = pipe()
        out_r, out_w = pipe()
        err_r, err_w = pipe()
        gate_r, gate_w = pipe()
        start = time.monotonic()  # Launch-relative, includes fork and gate setup.
        pid = os.fork()
        if pid == 0:
            try:
                for fd in (iw, out_r, err_r, gate_w):
                    os.close(fd)
                # No interpreter exec / collector work until parent owns a pidfd.
                # EOF on acquisition failure or parent death is a refusal.
                if not select.select([gate_r], [], [], GATE_SECONDS)[0]:
                    os._exit(125)
                if os.read(gate_r, 1) != b'G':
                    os._exit(125)
                os.close(gate_r)
                for old, new in ((ir, 0), (out_w, 1), (err_w, 2)):
                    os.dup2(old, new)
                    if old != new:
                        os.close(old)
                os.execv(PYTHON, ARGV)
            except BaseException:
                os._exit(126)
        for fd in (ir, out_w, err_w, gate_r):
            close(fd)
        pfd = os.pidfd_open(pid, 0)
        fds.add(pfd)
        signal.pidfd_send_signal(pfd, 0, None, 0)
        for fd in (iw, out_r, err_r):
            os.set_blocking(fd, False)
        os.write(gate_w, b'G')
        close(gate_w)
        offset = 0
        reads = {out_r: stdout, err_r: stderr}
        term_sent = kill_sent = False
        exited = False
        while reads or not exited:
            elapsed = time.monotonic() - start
            if not exited:
                for sig in due(elapsed, term_sent, kill_sent):
                    timed_out = True
                    if sig == signal.SIGTERM:
                        term_sent = True
                    else:
                        kill_sent = True
                    send(sig)
            rr, ww, _ = select.select(
                list(reads) + ([] if exited else [pfd]),
                [iw] if iw in fds else [], [], 0.05)
            if pfd in rr:
                exited = True
                close(iw)
            for fd in list(reads):
                if fd not in rr:
                    continue
                try:
                    block = os.read(fd, min(65536, CAP - len(reads[fd]) + 1))
                except BlockingIOError:
                    continue
                if not block:
                    close(fd)
                    del reads[fd]
                else:
                    room = CAP - len(reads[fd])
                    reads[fd].extend(block[:room])
                    if len(block) > room:
                        raise RuntimeError('output_limit_' + ('stdout' if fd == out_r else 'stderr'))
            if iw in ww and iw in fds:
                try:
                    offset += os.write(iw, data[offset:offset + 65536])
                except BlockingIOError:
                    continue
                if offset == len(data):
                    close(iw)
        if offset != len(data):
            errors.append('input_incomplete')
    except BaseException as exc:
        errors.append(type(exc).__name__ + ':' + str(exc))
    finally:
        # Closing the gate first ensures a failed acquisition cannot start work.
        if 'gate_w' in locals():
            close(gate_w)
        if pid is not None and pid > 0:
            if pfd is not None:
                try:
                    # Error cleanup uses only this exact owned pidfd, never PID.
                    if errors:
                        send(signal.SIGKILL)
                except BaseException as exc:
                    errors.append('cleanup_signal:' + type(exc).__name__ + ':' + str(exc))
            # With no pidfd, gate EOF/time limit exits the inert child; no fallback
            # signal. A blocked kernel syscall can delay this wait indefinitely.
            try:
                _, status = os.waitpid(pid, 0)
                reaped = True
            except BaseException as exc:
                errors.append('reap:' + type(exc).__name__ + ':' + str(exc))
        # Preserve still-buffered partial/error evidence after a channel failure.
        # Child has been reaped; bounded nonblocking drain cannot wait on writers.
        if reaped:
            for name, buffer in (('out_r', stdout), ('err_r', stderr)):
                fd = locals().get(name)
                if fd not in fds:
                    continue
                try:
                    os.set_blocking(fd, False)
                    while True:
                        block = os.read(fd, min(65536, CAP - len(buffer) + 1))
                        if not block:
                            break
                        room = CAP - len(buffer)
                        buffer.extend(block[:room])
                        if len(block) > room:
                            errors.append('cleanup_output_limit_' + name)
                            break
                except BlockingIOError:
                    pass
                except OSError as exc:
                    errors.append('drain:' + str(exc))
        for fd in list(fds):
            try:
                close(fd)
            except OSError as exc:
                errors.append('close:' + str(exc))
    result = dict(authorization=False, ready_for_build=False, vendor_run=False,
                  terminal='INCOMPLETE', errors=errors, timed_out=timed_out,
                  reaped=reaped, wait_status=status, elapsed=time.monotonic() - start,
                  collector_sha256=digest(data), collector_length=len(data))
    for name, value in (('stdout', stdout), ('stderr', stderr)):
        value = bytes(value)
        result[name] = dict(length=len(value), sha256=digest(value),
                            base64=base64.b64encode(value).decode('ascii'))
    try:
        report = json.loads(stdout)
        good = (isinstance(report, dict) and
                report.get('terminal', {}).get('result') == 'completed' and
                all(report.get(k) is False for k in
                    ('authorization', 'ready_for_build', 'vendor_run')))
    except (ValueError, TypeError, AttributeError):
        good = False
    if not errors and not timed_out and reaped and status == 0 and good:
        result['terminal'] = 'completed'
    return result


def emit(result):
    # Bounded nonblocking outer channel; never let a stuck reader trap launcher.
    # If transport fails, receiver MUST reject missing/truncated final JSON.
    data = (json.dumps(result, separators=(',', ':')) + '\n').encode('ascii')
    fd = sys.stdout.fileno()
    previous = os.get_blocking(fd)
    try:
        os.set_blocking(fd, False)
        end = time.monotonic() + OUTPUT_SECONDS
        offset = 0
        while offset < len(data):
            remaining = end - time.monotonic()
            if remaining <= 0 or not select.select([], [fd], [], remaining)[1]:
                return False
            try:
                offset += os.write(fd, data[offset:offset + 65536])
            except BlockingIOError:
                continue
        return True
    except OSError:
        return False
    finally:
        os.set_blocking(fd, previous)


def main():
    try:
        data = source()
        attest()
        result = run_child(data)
    except BaseException as exc:
        result = dict(authorization=False, ready_for_build=False, vendor_run=False,
                      terminal='INCOMPLETE', errors=[type(exc).__name__ + ':' + str(exc)])
    result['launcher_binding'] = globals().get('LAUNCHER_BINDING')
    ok = emit(result)
    return 0 if ok and result['terminal'] == 'completed' else 1


if __name__ == '__main__':
    sys.exit(main())
