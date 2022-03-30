import pytest
import requests
import os

app_url = os.environ.get('WAF_TEST_APP_URL')

test_strings = []
with open('../../../waf-test-files/test_strings.txt') as f:
    for line in f:
        test_strings.append(line.strip('\n'))

@pytest.mark.parametrize("test_string", test_strings)
def test_path(test_string):
    """Request blocked for string in url path"""
    r = requests.get(app_url + f"/" + test_string)
    assert r.status_code == 403

@pytest.mark.parametrize("test_string", test_strings)
@pytest.mark.parametrize("header", ["user-agent", "accept"])
def test_header_bodies(header, test_string):
    """Request blocked for string as value of header"""
    headers = {header: test_string}
    r = requests.get(app_url, headers=headers)
    assert r.status_code == 403

@pytest.mark.parametrize("test_string", test_strings)
def test_query_string(test_string):
    """Request blocked for string as the value of query"""
    payload = f"foo={test_string}"
    r = requests.get(app_url, params=payload)
    assert r.status_code == 403

@pytest.mark.parametrize("test_string", test_strings)
def test_query_string_reverse(test_string):
    """Request blocked for string as the key of a query"""
    payload = f"{test_string}=foo"
    r = requests.get(app_url, params=payload)
    assert r.status_code == 403

@pytest.mark.parametrize("test_string", test_strings)
def test_body(test_string):
    """Request blocked for string as part of the body"""
    r = requests.post(app_url+ f"/", data=test_string)
    assert r.status_code == 403