class WemosD1Mini:
    D0 = {'Name': 'D0', 'GPIO': 16, 'Use': 'WAKE', 'Input': 'no interrupt', 'Output': 'no PWM or I2C support', 'Notes': 'HIGH at boot, used to wake up from deep sleep, no interrupts'}
    D1 = {'Name': 'D1', 'GPIO': 5, 'Use': 'SCL', 'Input': 'OK', 'Output': 'OK', 'Notes': 'Often used as SCL (I2C), safer to use to operate relays'}
    D2 = {'Name': 'D2', 'GPIO': 4, 'Use': 'SDA', 'Input': 'OK', 'Output': 'OK', 'Notes': 'Often used as SDA (I2C), safer to use to operate relays'}
    D3 = {'Name': 'D3', 'GPIO': 0, 'Use': 'FLASH', 'Input': 'Pulled UP', 'Output': 'OK', 'Notes': 'Connected to FLASH button, boot fails if pulled LOW'}
    D4 = {'Name': 'D4', 'GPIO': 2, 'Use': 'LED', 'Input': 'Pulled UP', 'Output': 'OK', 'Notes': 'HIGH at boot, connected to on-board LED, boot fails if pulled LOW'}
    D5 = {'Name': 'D5', 'GPIO': 14, 'Use': 'SCLK', 'Input': 'OK', 'Output': 'OK', 'Notes': 'SPI (SCLK)'}
    D6 = {'Name': 'D6', 'GPIO': 12, 'Use': 'MISO', 'Input': 'OK', 'Output': 'OK', 'Notes': 'SPI (MISO)'}
    D7 = {'Name': 'D7', 'GPIO': 13, 'Use': 'MOSI', 'Input': 'OK', 'Output': 'OK', 'Notes': 'SPI (MOSI)'}
    D8 = {'Name': 'D8', 'GPIO': 15, 'Use': 'CS', 'Input': 'Pulled to GND', 'Output': 'OK', 'Notes': 'SPI (CS), boot fails if pulled HIGH'}
    RX = {'Name': 'RX', 'GPIO': 3, 'Use': 'RXD0', 'Input': 'OK', 'Output': 'RX pin', 'Notes': 'HIGH at boot'}
    TX = {'Name': 'TX', 'GPIO': 1, 'Use': 'TXD0', 'Input': 'TX pin', 'Output': 'OK', 'Notes': 'HIGH at boot, debug output at boot, boot fails if pulled LOW'}
    A0 = {'Name': 'A0', 'GPIO': 'ADC0', 'Use': 'Analog Input', 'Input': 'Analog Input', 'Output': 'X', 'Notes': 'Analog Input, voltage range (0V-1V)'}

    def __init__(self):
        self.pins = [WemosD1Mini.D0, WemosD1Mini.D1, WemosD1Mini.D2,
                     WemosD1Mini.D3, WemosD1Mini.D4, WemosD1Mini.D5,
                     WemosD1Mini.D6, WemosD1Mini.D7, WemosD1Mini.D8,
                     WemosD1Mini.RX, WemosD1Mini.TX, WemosD1Mini.A0]
        pass

    def __str__(self):
        # Wemos Pin name missing - to be completed !
        text = '\n  \033[01;36mWemosD1Mini Pinout\033[0m:'
        header = [['Name', 4], ['GPIO', 4], ['Use', 14], ['Input', 14], ['Output', 22], ['Notes', 72]]
        # divider = '------+------+----------------+----------------+---------------------------------------------------------------------------------'
        divider = ' +' + '+'.join(['-' * (h[1] + 2) for h in header]) + '+'
        # print(divider)
        text += '\n' + divider

        line = []
        for h in header:
            fmt = ' \033[01;34m{0:^' + str(h[1]) + '}\033[0m '
            line.append(fmt.format(h[0]))
        # print(' |' + '|'.join(line) + '|')
        text += '\n |' + '|'.join(line) + '|'

        # print(divider)
        text += '\n' + divider

        for p in self.pins:
            line = []
            for h in header:
                fmt = ' {0:^' + str(h[1]) + '} '
                line.append(fmt.format(p[h[0]]))
            # print(' |' + '|'.join(line) + '|')
            text += '\n |' + '|'.join(line) + '|'

        # print(divider)
        text += '\n' + divider + '\n'

        if 'HIGH' in text:
            text = text.replace('HIGH', '\033[01;32mHIGH\033[0m')
        if 'LOW' in text:
            text = text.replace('LOW', '\033[01;31mLOW\033[0m')
        if ' OK ' in text:
            text = text.replace(' OK ', ' \033[01;32mOK\033[0m ')
        if ' X ' in text:
            text = text.replace(' X ', ' \033[01;31mX\033[0m ')
        if '(' in text and ')' in text:
            text = text.replace('(', '(\033[01;33m')
            text = text.replace(')', '\033[0m)')

        return text


if __name__ == '__main__':
    WD1M = WemosD1Mini()
    print(str(WD1M))
