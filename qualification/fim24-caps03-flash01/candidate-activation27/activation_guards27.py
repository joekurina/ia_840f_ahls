"""Pure one-VF activation predicates; no hardware/filesystem operations."""
import re

ROOT = '0000:4e:00.0'
PF0 = '0000:4f:00.0'
PF1 = '0000:4f:00.1'
VF0 = '0000:4f:00.2'
CARD = frozenset([PF0, PF1, VF0])
GROUPS = frozenset(['4', '5', '76'])


def exact_set(values):
    values = list(values)
    assert all(isinstance(v, str) and re.fullmatch(r'[0-9a-f]{4}:[0-9a-f]{2}:[0-9a-f]{2}\.[0-7]', v) for v in values)
    assert len(values) == len(set(values)), 'duplicate PCI identity'
    return set(values)


def validate_population(rows, root_descendants):
    assert exact_set(root_descendants) == CARD
    assert len(rows) == 3 and {r['bdf'] for r in rows} == CARD
    entries = {r['bdf']: r for r in rows}
    for bdf, vendor, device, driver, group in [
        (PF0, '0x8086', '0xbcce', '/sys/bus/pci/drivers/dfl-pci', '4'),
        (PF1, '0x12ba', '0x0070', '/sys/bus/pci/drivers/vfio-pci', '5'),
        (VF0, '0x8086', '0xbccf', '/sys/bus/pci/drivers/vfio-pci', '76')]:
        r = entries[bdf]
        assert (r['vendor'], r['device'], r['driver']) == (vendor, device, driver)
        assert r['iommu_group'] == '/sys/kernel/iommu_groups/' + group
        assert r['group_members'] == [bdf]
        assert r['parent_path'] == '/sys/devices/pci0000:4e/' + ROOT
    assert entries[PF0]['sriov_numvfs'] == '1'
    assert entries[PF0]['virtfn_links'] == {'virtfn0': '/sys/devices/pci0000:4e/' + ROOT + '/' + VF0}
    assert entries[VF0]['physfn'] == '/sys/devices/pci0000:4e/' + ROOT + '/' + PF0
    return {'root': ROOT, 'bdfs': sorted(CARD), 'groups': sorted(GROUPS)}


def exact_delta(before, after, removed):
    before, after, removed = exact_set(before), exact_set(after), exact_set(removed)
    assert ROOT in before and ROOT in after
    assert before - after == removed, 'unexpected removal or missing cascade'
    assert not after - before, 'unexpected PCI addition'
    return True


def after_pf1(before, after, root_descendants):
    assert exact_set(root_descendants) == {PF0, VF0}
    return exact_delta(before, after, [PF1])


def after_pf0(initial, after_pf1_names, final, root_descendants):
    assert not list(root_descendants)
    exact_delta(after_pf1_names, final, [PF0, VF0])
    return exact_delta(initial, final, sorted(CARD))


def retained_owner_scope(scope):
    assert scope == {'root': ROOT, 'bdfs': sorted(CARD), 'groups': sorted(GROUPS)}
    return {'bdfs': list(scope['bdfs']), 'vfio_nodes': ['/dev/vfio/vfio'] + ['/dev/vfio/' + g for g in scope['groups']]}


def card_target(target, scope):
    """Recognize original device handles even after nodes disappear."""
    retained = retained_owner_scope(scope)
    if target in retained['vfio_nodes'] or target in [n + ' (deleted)' for n in retained['vfio_nodes']]:
        return True
    if target.startswith('/dev/dfl-'):
        return True
    return any(re.search('/' + re.escape(bdf) + r'/resource[0-5](?:_wc)?(?: \(deleted\))?$', target) for bdf in retained['bdfs'])


def card_mapping(line, scope):
    fields = line.split(None, 5)
    return len(fields) == 6 and card_target(fields[5], scope)
