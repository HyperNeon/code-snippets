angular.module('angular_comments', [/REDACTED/]);
angular.module('angular_comments').controller('AccordionCtrl',['$scope', function($scope) {
    $scope.oneAtATime = false;
    $scope.statuses = [];

    $scope.toggle = function(type, state) {

        angular.forEach($scope.statuses, function(status) {
            status.open = state;
        });
    };
}]);