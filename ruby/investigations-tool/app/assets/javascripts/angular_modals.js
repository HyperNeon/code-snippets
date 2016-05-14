angular.module('angular_modals', [/REDACTED/]);
angular.module('angular_modals').controller('ModalCtrl', ['$scope', '$modal', function($scope, $modal) {
    $scope.open = function (template) {
        $modal.open({
            templateUrl: template,
            controller: 'ModalInstanceCtrl'
        });
    };
}]).controller('ModalInstanceCtrl', ['$scope', '$modalInstance', function($scope, $modalInstance) {
    $scope.ok = function () {
        $modalInstance.close();
    };
    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };
}]);

angular.module('assignee_typeahead', [/REDACTED/]);
angular.module('assignee_typeahead').controller('TypeaheadCtrl', ['$scope', '$http', function($scope, $http) {
    $scope.selected = undefined;

    $scope.getUsers = function(val) {
        return $http.get('/search_jira_users/', {
            params: {
                username: val
            }
        }).then(function(response){
            return response.data
        });
    };

}]);
