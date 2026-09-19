#!/usr/bin/env python

# Copyright 2024 Intel Corporation
# SPDX-License-Identifier: MIT

import fileinput
import glob
import os
import re
import logging
import logging.handlers


class Project:
    """
    Class used for configuring OFS Quartus projects.

    Updates QSF files from OFSS configuration.
    """
    def __init__(self, ofs_config, target):
        self.ofs_config = ofs_config
        self.target = target
        self.__get_ip_settings()

    def __get_ip_settings(self):
        """
        Get IP settings from configuration dictionary
        """
        self.part = self.ofs_config["settings"]["part"]

    def summarize_configuration(self):
        """
        Quartus Project Summary
        """
        logging.info("")
        logging.info("=========================")
        logging.info("Quartus Project Summary")
        logging.info("=========================")
        logging.info(f"Part = {self.part}")
        logging.info("")

    def deploy(self):
        """
        Update Quartus poject.
        """
        qsf_files = glob.glob('*.qsf')
        for qsf in qsf_files:
            dev = self.__get_current_part(qsf)
            if dev and dev != self.part:
                logging.info(f"Changing {qsf} device from {dev} to {self.part}")
                self.__update_part(qsf)

    def __get_current_part(self, qsf_name):
        """
        Return the current part (device) in a QSF file.
        """
        dev = None

        for line in fileinput.input([qsf_name]):
            m = re.match(r'\s*set_global_assignment\s+-name\s+DEVICE\s+([^\s]+)', line)
            if m:
                dev = m.group(1)

        return dev

    def __update_part(self, qsf_name):
        """
        Change the part (device) in a QSF file.
        """
        for line in fileinput.input([qsf_name], inplace=True):
            s = re.sub(r'(\s*set_global_assignment\s+-name\s+DEVICE\s+)([^\s]+)',
                       f"\\g<1>{self.part}", line)
            print(s, end="")
