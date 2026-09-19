import pathlib
S=pathlib.Path.home()/'.local/lib/python3.9/site-packages'
for f in ['bw_core/utils/semaphore/linux.py','bw_kit/kit_bmc_handler.py']:
 print('SOURCE',f);print((S/f).read_text())
