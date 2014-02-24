# -*- coding: utf-8 -*-
#
# Copyright 2013 - Mirantis, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.


from mistral.workbook import base


class TaskSpec(base.BaseSpec):
    _required_keys = ['name', 'action']

    def __init__(self, task):
        super(TaskSpec, self).__init__(task)
        self._prepare(task)
        if self.validate():
            self.requires = task['requires']
            self.action = task['action']
            self.name = task['name']
            self.parameters = task.get('parameters', {})

    def _prepare(self, task):
        if task:
            req = task.get("requires", {})
            if req and isinstance(req, list):
                task["requires"] = dict(zip(req, ['']*len(req)))
            elif isinstance(req, dict):
                task['requires'] = req

    def get_property(self, property_name, default=None):
        return self._data.get(property_name, default)

    def get_on_error(self):
        task = self.get_property("on-error")
        if task:
            return task if isinstance(task, dict) else {task: ''}
        return None

    def get_on_success(self):
        task = self.get_property("on-success")
        if task:
            return task if isinstance(task, dict) else {task: ''}
        return None

    def get_on_finish(self):
        task = self.get_property("on-finish")
        if task:
            return task if isinstance(task, dict) else {task: ''}
        return None

    def get_action_service(self):
        return self.action.split(':')[0]

    def get_action_name(self):
        return self.action.split(':')[1]


class TaskSpecList(base.BaseSpecList):
    item_class = TaskSpec