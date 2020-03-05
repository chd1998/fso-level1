import fire
import datetime

def cal_days(date_str1, date_str2):
    '''计算两个日期之间的天数'''

    date_str1 = str(date_str1)
    date_str2 = str(date_str2)
    d1 = datetime.datetime.strptime(date_str1, '%Y%m%d')
    d2 = datetime.datetime.strptime(date_str2, '%Y%m%d')
    delta = d1 - d2
    return delta.days


if __name__ == '__main__':
    fire.Fire(cal_days)